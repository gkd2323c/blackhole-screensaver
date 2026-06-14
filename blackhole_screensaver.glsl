// blackhole_screensaver.glsl — adapted from s0xDk/ghostty-blackhole for standalone screensaver
// Replaces terminal text background with procedural deep-space starfield
// Forces demo mode (self-running 42s showcase loop with preset rotation)
// Original: https://github.com/s0xDk/ghostty-blackhole (MIT License)

// ---------------------------------------------------------------- tunables --
const float HOLE_RADIUS   = 0.0200;
const float LENS_DEPTH    = 13.0000;
const float STAR_GAIN     = 0.3000;  // brighter stars since no terminal text
const float DISK_INNER    = 1.8000;
const float DISK_OUTER    = 8.0000;
const float DISK_INCL     = 1.5000;
const float DISK_ROLL     = 0.3500;
const float DISK_GAIN     = 2.2000;
const float DISK_OPACITY  = 0.9000;
const float DISK_TEMP     = 5500.0000;
const float DOPPLER_MIX   = 0.6000;
const float DISK_BEAM     = 2.5000;
const float DISK_SPEED    = 5.0000;
const float DISK_WIND     = 7.0000;
const float DISK_CONTRAST = 1.6000;
const float EXPOSURE      = 1.4000;
const float DRIFT_SPEED   = 1.0000;
const float WORK_AREA     = 0.0;      // no work area — full screen
const float DILATION_MIN  = 0.2000;

#define N_STEPS 48

// Force demo mode — self-running showcase loop
#define MODE_DEMO 2
#define SIZE_MODE MODE_DEMO

const float DEMO_SEC      = 42.0000;
const float DEMO_GROW_SEC = 40.0000;
const float DEMO_XFADE    = 0.1800;

struct DiskLook {
    float temp, incl, roll, inner, outer, opac, dopp, beam,
          gain, contr, wind, speed, expo, star;
};
const DiskLook LOOK_DEFAULT = DiskLook(
    DISK_TEMP, DISK_INCL, DISK_ROLL, DISK_INNER, DISK_OUTER, DISK_OPACITY,
    DOPPLER_MIX, DISK_BEAM, DISK_GAIN, DISK_CONTRAST, DISK_WIND, DISK_SPEED,
    EXPOSURE, STAR_GAIN);
#define DEMO_N 8
const DiskLook DEMO_TOUR[DEMO_N] = DiskLook[DEMO_N](
    DiskLook( 5500.0, 1.50,  0.35, 1.8,  8.0, 0.90, 0.60, 2.5, 2.2, 1.6, 7.0, 5.0, 1.40, 0.3),
    DiskLook( 4500.0, 1.52,  0.10, 2.2,  7.0, 0.85, 0.35, 2.0, 1.4, 0.5, 7.0, 5.0, 1.20, 0.3),
    DiskLook( 3800.0, 0.55, -0.30, 2.2,  6.0, 0.45, 0.90, 3.5, 1.6, 0.4, 3.0, 2.5, 1.10, 0.3),
    DiskLook( 6500.0, 0.30,  0.00, 3.0, 10.0, 0.50, 0.80, 2.5, 1.0, 1.1, 7.0, 5.0, 1.00, 0.3),
    DiskLook(15000.0, 1.30,  0.35, 3.0, 14.0, 0.35, 1.00, 4.0, 1.2, 1.3, 8.0, 5.0, 0.80, 0.3),
    DiskLook(18000.0, 1.05,  0.55, 3.0, 16.0, 0.30, 1.00, 5.0, 1.0, 1.5, 9.0, 6.0, 0.75, 0.3),
    DiskLook( 5500.0, 1.50,  0.35, 1.8,  8.0, 0.00, 1.00, 2.5, 0.0, 1.6, 7.0, 5.0, 1.00, 0.6),
    DiskLook( 5500.0, 1.50,  0.35, 1.8,  8.0, 0.90, 0.60, 2.5, 2.2, 1.6, 7.0, 5.0, 1.40, 0.3));

DiskLook mixLook(DiskLook a, DiskLook b, float f) {
    return DiskLook(
        mix(a.temp,  b.temp,  f), mix(a.incl,  b.incl,  f),
        mix(a.roll,  b.roll,  f), mix(a.inner, b.inner, f),
        mix(a.outer, b.outer,  f), mix(a.opac,  b.opac,  f),
        mix(a.dopp,  b.dopp,  f), mix(a.beam,  b.beam,  f),
        mix(a.gain,  b.gain,  f), mix(a.contr, b.contr, f),
        mix(a.wind,  b.wind,  f), mix(a.speed, b.speed, f),
        mix(a.expo,  b.expo,  f), mix(a.star,  b.star,  f));
}

DiskLook demoLook() {
    float u = mod(iTime, DEMO_SEC) / DEMO_SEC * float(DEMO_N);
    int   i = int(min(u, float(DEMO_N) - 0.001));
    float f = smoothstep(1.0 - DEMO_XFADE, 1.0, fract(u));
    return mixLook(DEMO_TOUR[i], DEMO_TOUR[(i + 1) % DEMO_N], f);
}

#define B_CRIT 2.5980762

// ------------------------------------------------------------------- noise --
float hash21(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

float vnoiseWrapY(vec2 p, float perY) {
    vec2 i = floor(p), f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float y0 = mod(i.y, perY), y1 = mod(i.y + 1.0, perY);
    return mix(mix(hash21(vec2(i.x, y0)),       hash21(vec2(i.x + 1.0, y0)), f.x),
               mix(hash21(vec2(i.x, y1)),       hash21(vec2(i.x + 1.0, y1)), f.x),
               f.y);
}

vec2 mirrorUV(vec2 u) { return 1.0 - abs(1.0 - mod(u, 2.0)); }

vec2 rot(vec2 v, float a) {
    float c = cos(a), s = sin(a);
    return vec2(c * v.x - s * v.y, s * v.x + c * v.y);
}

vec2 lissa(float t) {
    return vec2(0.75 * sin(t * 0.37) + 0.25 * sin(t * 0.83 + 1.0),
                0.70 * sin(t * 0.54 + 2.1) + 0.30 * sin(t * 1.07));
}

vec3 blackbody(float T) {
    float t = clamp(T, 1500.0, 40000.0) / 100.0;
    float r = t <= 66.0 ? 1.0
                        : clamp(1.292936 * pow(t - 60.0, -0.1332047), 0.0, 1.0);
    float g = t <= 66.0 ? clamp(0.3900816 * log(t) - 0.6318414, 0.0, 1.0)
                        : clamp(1.1298909 * pow(t - 60.0, -0.0755148), 0.0, 1.0);
    float b = t >= 66.0 ? 1.0
                        : (t <= 19.0 ? 0.0
                                     : clamp(0.5432068 * log(t - 10.0) - 1.1962540, 0.0, 1.0));
    return vec3(r, g, b);
}

vec3 stars(vec3 d) {
    vec2 sph = vec2(atan(d.x, -d.z), asin(clamp(d.y, -1.0, 1.0)));
    vec2 g   = sph * 40.0;
    vec2 id  = floor(g);
    float h  = hash21(id);
    if (h < 0.92) return vec3(0.0);
    vec2 f   = fract(g) - 0.5;
    vec2 off = (vec2(hash21(id + 17.3), hash21(id + 31.7)) - 0.5) * 0.7;
    float spark = smoothstep(0.10, 0.0, length(f - off));
    float tw    = 0.7 + 0.3 * sin(iTime * (0.5 + 2.0 * hash21(id + 5.1)) + 40.0 * h);
    vec3 tint   = mix(vec3(1.0, 0.82, 0.60), vec3(0.75, 0.85, 1.0), hash21(id + 2.9));
    return tint * spark * tw * ((h - 0.92) / 0.08);
}

// procedural deep-space background to replace terminal text
vec3 spaceBackground(vec2 uv) {
    // dark base with subtle nebula
    float n1 = hash21(floor(uv * 8.0));
    float n2 = hash21(floor(uv * 16.0));
    float n3 = hash21(floor(uv * 32.0));
    float nebula = n1 * 0.3 + n2 * 0.15 + n3 * 0.05;
    // subtle color variation
    vec3 nebColor = mix(
        vec3(0.02, 0.01, 0.04),
        vec3(0.04, 0.02, 0.06),
        sin(n1 * 6.28 + 1.0) * 0.5 + 0.5);
    return nebColor * (0.5 + nebula);
}

// ------------------------------------------------------------------- image --
// Uniforms provided by host:
//   uniform float iTime;
//   uniform vec2  iResolution;
// Provided by shader (for Shadertoy compatibility, unused in screensaver):
float iTime;
vec2  iResolution;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2  res    = iResolution.xy;
    vec2  uv     = fragCoord / res;
    float aspect = res.x / res.y;
    float yUp    = 1.0 - uv.y;
    float t      = iTime * DRIFT_SPEED;

    DiskLook L = demoLook();

    float rin  = max(L.inner, 1.6);
    float rout = max(L.outer, rin + 0.5);

    // demo mode: self-running loop
    float lvl = min(mod(iTime, DEMO_SEC) / DEMO_GROW_SEC, 1.0);
    float g   = lvl;
    float I   = mix(0.10, 1.0, g);

    float vis = smoothstep(0.0, 0.10, I);
    if (vis <= 0.0) {
        fragColor = vec4(spaceBackground(uv), 1.0);
        return;
    }

    // size: same as token mode area calibration
    float aspect = res.x / res.y;
    float rhMin  = sqrt(0.010 * aspect / 3.1415927);
    float rhMax  = sqrt(0.500 * aspect / 3.1415927);
    float rhT    = mix(rhMin, rhMax, g) * (HOLE_RADIUS / 0.08);
    float sz     = rhT / max(HOLE_RADIUS, 1e-4);

    // movement: roam box growing from corner, same as token mode
    float marg = min(rhT * mix(1.45, 0.90, g), 0.5 * 0.97);
    float xPad = marg / aspect;
    vec2  fullLo = vec2(min(xPad, 0.5), marg);
    vec2  fullHi = vec2(max(0.5, 1.0 - xPad), max(marg, 0.97 - marg));
    vec2  corner = clamp(vec2(0.96, 0.04), fullLo, fullHi);
    float reach  = mix(0.06, max(1.0, 0.06), g);
    vec2  lo = vec2(mix(corner.x, fullLo.x, reach), fullLo.y);
    vec2  hi = vec2(fullHi.x, mix(corner.y, fullHi.y, reach));
    vec2  room   = max((hi - lo) * 0.5, vec2(0.0));
    vec2  wobAmp = min(vec2(0.010 + 0.030 * g), max(room * 0.35, vec2(0.006)));
    vec2  ampEff = max(room - wobAmp, vec2(0.0));
    vec2  wander = lissa(t * 0.04);
    vec2  center = (lo + hi) * 0.5 + wander * ampEff
                 + wobAmp * vec2(cos(t * 0.8), sin(t * 1.0));

    float rh = HOLE_RADIUS * sz;
    float dil = mix(1.0, DILATION_MIN, I);
    float shield = vis * smoothstep(WORK_AREA, WORK_AREA + 0.18, yUp);

    vec2  p    = (uv - center) * vec2(aspect, 1.0);
    float plen = length(p);

    float W  = B_CRIT / max(rh, 1e-4);
    vec2  pr = rot(vec2(p.x, -p.y), L.roll) * W;
    float b  = length(pr);

    float window = exp(-pow(plen / (7.0 * rh), 2.0));
    float bmax = rout + 3.0;
    float Z0   = max(14.0, rout + 5.0);

    // ================= far field: analytic weak deflection ==================
    if (b >= bmax) {
        float u    = Z0 * inversesqrt(Z0 * Z0 + b * b);
        float defl = (2.0 / (W * W)) / max(plen, 1e-4)
                   * (1.29 * u + 0.07) * max(LENS_DEPTH - 2.14 * u + 0.75, 0.0)
                   * window * shield;
        vec2  dir  = p / max(plen, 1e-5);
        vec3  term;
        float ab = 0.035 * smoothstep(1.0, 2.0, b / bmax);
        for (int i = 0; i < 3; i++) {
            float k   = 1.0 + (float(i) - 1.0) * ab;
            vec2  sp  = p - dir * defl * k;
            vec2  suv = mirrorUV(center + sp / vec2(aspect, 1.0));
            term[i]   = spaceBackground(suv)[i];
        }
        vec3 d = normalize(vec3(-(pr / b) * (2.0 / b), -1.0));
        fragColor = vec4(term + stars(d) * L.star * window * shield, 1.0);
        return;
    }

    // ====================== near field: trace the geodesic ==================
    vec3  x  = vec3(pr, Z0);
    vec3  v  = vec3(0.0, 0.0, -1.0);
    float h2 = dot(pr, pr);

    float ci = cos(L.incl), si = sin(L.incl);
    vec3  n  = vec3(0.0, si, ci);
    vec3  e2 = vec3(0.0, ci, -si);
    float sdir = L.speed < 0.0 ? -1.0 : 1.0;
    float spd  = abs(L.speed);

    vec3  emitc = vec3(0.0);
    float trans = 1.0;
    bool  captured = false;
    float sPrev = dot(x, n);
    vec3  xPrev = x;

    for (int i = 0; i < N_STEPS; i++) {
        float r2 = dot(x, x);
        if (r2 < 1.0) { captured = true; break; }
        if (x.z < -Z0 && v.z < 0.0) break;
        if (r2 > 4.0 * Z0 * Z0) break;
        float r  = sqrt(r2);
        float dt = clamp(0.16 * r, 0.03, 1.5);
        vec3 a = -1.5 * h2 * x / (r2 * r2 * r);
        v += a * (0.5 * dt);
        x += v * dt;
        r2 = dot(x, x);
        r  = sqrt(r2);
        a  = -1.5 * h2 * x / (r2 * r2 * r);
        v += a * (0.5 * dt);

        float s = dot(x, n);
        if (s * sPrev < 0.0 && trans > 0.02) {
            float tc = sPrev / (sPrev - s);
            vec3  xc = mix(xPrev, x, tc);
            float rc = length(xc);
            if (rc > rin && rc < rout) {
                float band = smoothstep(rin, rin * 1.25, rc)
                           * (1.0 - smoothstep(rout * 0.70, rout, rc));
                float phi   = atan(dot(xc, e2), xc.x);
                float turns = phi / 6.2831853;
                float kep   = pow(rin / rc, 1.5);
                float gloc  = sqrt(max(1.0 - 1.5 / rc, 0.02));
                float swirl = rc * L.wind * 0.12 - t * kep * spd * gloc * dil * sdir;
                float streaks = vnoiseWrapY(vec2(rc * 2.8, turns * 19.0 + swirl * 3.0), 19.0) * 0.65 +
                                vnoiseWrapY(vec2(rc * 1.0, turns * 9.0  + swirl * 1.5 + 7.0), 9.0) * 0.35;
                streaks = 0.35 + L.contr * streaks * streaks;
                vec3  gasdir = normalize(cross(n, xc)) * sdir;
                float beta   = clamp(inversesqrt(max(2.0 * (rc - 1.0), 0.2)), 0.0, 0.99);
                float g2     = gloc / max(1.0 + beta * dot(gasdir, normalize(v)), 0.05);
                g2 = mix(1.0, g2, L.dopp);
                float xpr   = max(1.0 - sqrt(rin / rc), 0.0);
                float tprof = pow(rin / rc, 0.75) * pow(xpr, 0.25) / 0.488;
                vec3  cbb   = blackbody(L.temp * tprof * g2);
                float boost = pow(g2, L.beam);
                float density = band * streaks;
                emitc += trans * cbb * (L.gain * 2.2 * density * tprof * tprof * boost);
                trans *= 1.0 - clamp(L.opac * density, 0.0, 1.0);
            }
        }
        sPrev = s;
        xPrev = x;
    }
    if (!captured && dot(x, x) < 4.0) captured = true;

    vec3 bg = vec3(0.0);
    if (!captured) {
        vec3 d = normalize(v);
        bg += stars(d) * L.star * window * shield;
        if (d.z < -0.05) {
            float tpl = (-LENS_DEPTH - x.z) / d.z;
            vec3  hp  = x + d * tpl;
            vec2  q   = rot(hp.xy, -L.roll) / W;
            vec2  sp  = vec2(q.x, -q.y);
            vec2  suv = mirrorUV(center + (p + (sp - p) * window * shield) / vec2(aspect, 1.0));
            float toward = smoothstep(0.05, 0.35, -d.z);
            bg += spaceBackground(suv) * toward;
        }
    }

    vec3 col = bg * trans + (vec3(1.0) - exp(-emitc * L.expo));
    fragColor = vec4(col, 1.0);
}
