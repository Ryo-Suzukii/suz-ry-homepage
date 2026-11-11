// 天体の位置計算。恒星は J2000 の赤経・赤緯、惑星と月は astronomy-engine で求める。
import { Body, Equator, Illumination, MakeTime, Observer, SiderealTime } from "astronomy-engine"

const RAD = Math.PI / 180

// 観測地点。細かい場所は出さず、日本の関東あたりの緯度経度に丸めている。
export const SITE = { lat: 35.7, lon: 139.7 }

const observer = new Observer(SITE.lat, SITE.lon, 0)

export function dirFromRaDec(raDeg, decDeg) {
  const ra = raDeg * RAD
  const dec = decDeg * RAD
  const c = Math.cos(dec)
  return [c * Math.cos(ra), c * Math.sin(ra), Math.sin(dec)]
}

// 地方恒星時 (rad)
export function localSiderealTime(date) {
  const hours = SiderealTime(MakeTime(date)) + SITE.lon / 15
  return (((hours % 24) + 24) % 24) * 15 * RAD
}

// 赤道座標 → 地平座標 (東, 北, 天頂) の回転行列。行優先の 9 要素。
export function equatorialToHorizontal(lst) {
  const sl = Math.sin(lst)
  const cl = Math.cos(lst)
  const sp = Math.sin(SITE.lat * RAD)
  const cp = Math.cos(SITE.lat * RAD)
  return [-sl, cl, 0, -sp * cl, -sp * sl, cp, cp * cl, cp * sl, sp]
}

// 地平座標 → カメラ座標 (右, 上, 奥)。az は北から東回り。
export function horizontalToCamera(az, alt) {
  const sa = Math.sin(az)
  const ca = Math.cos(az)
  const sh = Math.sin(alt)
  const ch = Math.cos(alt)
  return [ca, -sa, 0, -sa * sh, -ca * sh, ch, sa * ch, ca * ch, sh]
}

export function mul3(a, b) {
  const out = new Array(9)
  for (let r = 0; r < 3; r++) {
    for (let c = 0; c < 3; c++) {
      out[r * 3 + c] = a[r * 3] * b[c] + a[r * 3 + 1] * b[3 + c] + a[r * 3 + 2] * b[6 + c]
    }
  }
  return out
}

export function apply3(m, v) {
  return [
    m[0] * v[0] + m[1] * v[1] + m[2] * v[2],
    m[3] * v[0] + m[4] * v[1] + m[5] * v[2],
    m[6] * v[0] + m[7] * v[1] + m[8] * v[2],
  ]
}

export function transpose3(m) {
  return [m[0], m[3], m[6], m[1], m[4], m[7], m[2], m[5], m[8]]
}

const PLANETS = [
  { body: Body.Mercury, name: "水星", color: [0.92, 0.88, 0.82] },
  { body: Body.Venus, name: "金星", color: [1.0, 0.98, 0.9] },
  { body: Body.Mars, name: "火星", color: [1.0, 0.62, 0.42] },
  { body: Body.Jupiter, name: "木星", color: [1.0, 0.93, 0.8] },
  { body: Body.Saturn, name: "土星", color: [1.0, 0.9, 0.68] },
]

function bodyDir(body, time) {
  const eq = Equator(body, time, observer, false, true)
  return dirFromRaDec(eq.ra * 15, eq.dec)
}

// 太陽・月・惑星のいまの位置
export function solarSystem(date) {
  const time = MakeTime(date)
  return {
    sun: { dir: bodyDir(Body.Sun, time) },
    moon: {
      name: "月",
      dir: bodyDir(Body.Moon, time),
      lit: Illumination(Body.Moon, time).phase_fraction,
    },
    planets: PLANETS.map((p) => ({
      name: p.name,
      color: p.color,
      dir: bodyDir(p.body, time),
      mag: Illumination(p.body, time).mag,
    })),
  }
}

// B-V 色指数 → 表示色。色温度に直してから黒体放射の近似色にする。
export function colorFromBV(bv) {
  const t = 4600 * (1 / (0.92 * bv + 1.7) + 1 / (0.92 * bv + 0.62))
  const k = Math.min(Math.max(t, 2000), 30000) / 100
  let r
  let g
  let b
  if (k <= 66) {
    r = 255
    g = 99.47 * Math.log(k) - 161.12
    b = k <= 19 ? 0 : 138.52 * Math.log(k - 10) - 305.04
  } else {
    r = 329.7 * (k - 60) ** -0.1332
    g = 288.12 * (k - 60) ** -0.0755
    b = 255
  }
  const clamp = (x) => Math.min(Math.max(x, 0), 255) / 255
  return [clamp(r), clamp(g), clamp(b)]
}
