import Foundation
import simd

struct SyncTuple {
    var displacement: Float
    var agcGain: Float
    var noiseAmp: Float
    var hfLoss: Float
}

public class BENDRVHSPLL {
    
    // Deterministic hash functions
    static func pcg_hash(_ input: UInt32) -> UInt32 {
        var state = input &* 747796405 &+ 2891336453
        var word = ((state >> ((state >> 28) &+ 4)) ^ state) &* 277803737
        return (word >> 22) ^ word
    }

    static func hashToFloat(_ h: UInt32) -> Float {
        return Float(h) / Float(UInt32.max)
    }

    static func h21(_ x: Float, _ y: Float) -> Float {
        let qx = UInt32(bitPattern: x)
        let qy = UInt32(bitPattern: y)
        return hashToFloat(pcg_hash(qx ^ pcg_hash(qy)))
    }
    
    static func vnoise1d(_ x: Float) -> Float {
        let i = floor(x)
        let f = x - i
        let sm = f * f * (3.0 - 2.0 * f)
        let h0 = hashToFloat(pcg_hash(UInt32(bitPattern: Float(i))))
        let h1 = hashToFloat(pcg_hash(UInt32(bitPattern: Float(i + 1.0))))
        return h0 * (1.0 - sm) + h1 * sm
    }
    
    public static func updateSyncModel(t: Float, params: BENDRVHSParams) -> [SyncTuple] {
        let rows = Int(params.rows)
        var results = [SyncTuple](repeating: SyncTuple(displacement: 0, agcGain: 1, noiseAmp: 0, hfLoss: 0), count: rows)
        
        let jit = params.jitter
        let wob = params.hWobble
        let wfq = params.wobbleFreq
        let wow = params.tapeWow
        let wowR = params.wowRate
        let flut = params.flutter
        let trk = params.tracking
        let tph = params.trackPhase
        let hunt = params.trackHunt
        let hsw = params.headSwitch
        let sp = params.tapeSpeed
        let stre = params.tapeStretch
        let crs = params.crease
        let crsP = params.creasePos
        let clog = params.headClog
        let azi = params.azimuth

        // deterministic track hunt
        let huntPh = t * (0.35 + hunt * 2.4)
        let huntTri = abs((fmod(huntPh * 0.5, 1.0)) * 2 - 1)
        let s_hunt = hunt * (huntTri - 0.5) * 0.55 + hunt * 0.10 * sin(huntPh * 9.3)
        
        // tracking v/c deterministic fake
        let trackC = 0.5 + 0.4 * sin(t * 0.2) // fake drift
        let bandC = min(0.97, max(0.03, trackC + tph * 0.45 + s_hunt))
        
        let clogC = 0.5 + 0.45 * sin(t * 0.1) // fake clog drift
        
        let creaseJ = vnoise1d(t * 22.0) * 0.5
        let hsRows = max(0, Int(Float(rows) * 0.05 * hsw * (1.0 + sp)))
        let bw = 0.035 + 0.05 * trk + hunt * 0.02
        let wowF1 = 5.2 * (0.25 + wowR * 3.0)
        let wowF2 = 17.0 * (0.25 + wowR * 3.0)
        let wowT1 = t * 0.9 * (0.3 + wowR * 2.6)
        let wowT2 = t * 1.4 * (0.3 + wowR * 2.6)
        let clogW = 0.012 + clog * 0.075
        let creaseW = 0.006 + crs * 0.03
        
        let SNC = 25
        
        for r in 0..<rows {
            let fy = Float(r) / Float(rows)
            var d = (sin(fy * wowF1 + wowT1) + 0.6 * sin(fy * wowF2 - wowT2)) * 0.006 * wow
                  + sin(fy * (6.0 + wfq * 80.0) + t * 4.2) * 0.013 * wob
            
            if flut > 0.003 {
                d += sin(fy * (120.0 + flut * 420.0) + t * 37.0) * 0.004 * flut
                   + sin(fy * 311.0 - t * 61.0) * 0.0022 * flut
            }
            if stre > 0.003 {
                let k = 1.0 - fy
                d += k * k * 0.06 * stre
            }
            
            let xc = fy * Float(SNC - 1)
            let ic = min(SNC - 2, Int(floor(xc)))
            let fc = xc - Float(ic)
            let sm = fc * fc * (3 - 2 * fc)
            
            // Generate pseudo-OU values deterministically
            let ouv0 = (vnoise1d(t * 6.0 + Float(ic) * 0.1) - 0.5) * 2.0
            let ouv1 = (vnoise1d(t * 6.0 + Float(ic + 1) * 0.1) - 0.5) * 2.0
            let oufv0 = (vnoise1d(t * 45.0 + Float(ic) * 0.1) - 0.5) * 2.0
            let oufv1 = (vnoise1d(t * 45.0 + Float(ic + 1) * 0.1) - 0.5) * 2.0
            
            let ouv = ouv0 * (1 - sm) + ouv1 * sm
            let oufv = oufv0 * (1 - sm) + oufv1 * sm
            
            d += ouv * 0.004 * (0.12 + jit)
            let g0 = (fy - bandC) / bw
            let bp = exp(-g0 * g0)
            d += bp * trk * oufv * 0.02
            
            var ng = bp * trk * (0.3 + 0.4 * abs(oufv))
            var hf = bp * trk * 0.35 + sp * 0.12
            
            if r < hsRows {
                let k = Float(hsRows - r) / Float(hsRows)
                d += (0.045 * k * k + 0.02 * k * oufv) * hsw
                ng += hsw * 0.9 * k * k
                hf += hsw * 0.5 * k
            }
            
            if clog > 0.003 {
                let gc = (fy - clogC) / clogW
                let cb = exp(-gc * gc)
                ng += cb * clog * 1.5
                hf += cb * clog
            }
            
            if crs > 0.003 {
                let gk = (fy - crsP) / creaseW
                let cb = exp(-gk * gk)
                d += cb * crs * (0.09 + 0.05 * creaseJ)
                ng += cb * crs * 0.8
                hf += cb * crs * 0.7
            }
            
            if azi > 0.003 {
                hf += azi * 0.75 * Float(r % 2)
            }
            
            let gn = 1 - min(0.38, abs(d) * 2.0) - min(0.5, ng * 0.18)
            
            results[r] = SyncTuple(displacement: d, agcGain: gn, noiseAmp: ng, hfLoss: min(1, hf))
        }
        
        return results
    }
}
