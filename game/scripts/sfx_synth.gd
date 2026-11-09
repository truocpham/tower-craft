class_name SfxSynth
extends RefCounted
## Generates every sound in code (no asset files, no downloads). All sounds are
## soft sines with gentle envelopes: no harsh or scary tones.

const RATE := 22050
## Major pentatonic steps in semitones; the chime climbs these on each perfect.
const SCALE := [0, 2, 4, 7, 9, 12, 14, 16, 19, 21, 24]


static func _to_stream(samples: PackedFloat32Array, rate: int, loop: bool = false) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():
		bytes.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.stereo = false
	w.data = bytes
	if loop:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = samples.size()
	return w


## Soft falling whoosh: a quiet sine gliding down.
static func drop() -> AudioStreamWAV:
	var n := int(RATE * 0.25)
	var s := PackedFloat32Array()
	s.resize(n)
	var ph := 0.0
	for i in n:
		var t := float(i) / n
		ph += TAU * lerpf(520.0, 300.0, t) / RATE
		s[i] = sin(ph) * 0.18 * sin(PI * t)
	return _to_stream(s, RATE)


## Soft landing thud: low sine with a quick decay.
static func thud() -> AudioStreamWAV:
	var n := int(RATE * 0.3)
	var s := PackedFloat32Array()
	s.resize(n)
	var ph := 0.0
	for i in n:
		var t := float(i) / n
		ph += TAU * lerpf(130.0, 60.0, minf(t * 3.0, 1.0)) / RATE
		s[i] = sin(ph) * 0.55 * exp(-t * 7.0) * minf(float(i) / 80.0, 1.0)
	return _to_stream(s, RATE)


static func chime_freq(streak: int) -> float:
	var step: int = SCALE[clampi(streak - 1, 0, SCALE.size() - 1)]
	return 523.25 * pow(2.0, step / 12.0)


## Bell-like chime; pitch rises with the streak (1 = first perfect).
static func chime(streak: int) -> AudioStreamWAV:
	var f := chime_freq(streak)
	var n := int(RATE * 0.6)
	var s := PackedFloat32Array()
	s.resize(n)
	for i in n:
		var t := float(i) / RATE
		var env := exp(-t * 6.0) * minf(t * 400.0, 1.0)
		s[i] = (sin(TAU * f * t) * 0.35 + sin(TAU * f * 2.0 * t) * 0.12 + sin(TAU * f * 3.0 * t) * 0.04) * env
	return _to_stream(s, RATE)


## Calm looping music: slow pentatonic arpeggio over soft pads, 16 s.
static func music() -> AudioStreamWAV:
	var rate := 11025
	var beat := 0.5
	var bars := 8
	var total := int(rate * beat * 4.0 * bars)
	var buf := PackedFloat32Array()
	buf.resize(total)
	var roots := [0, 5, 7, 0, 5, 9, 7, 0]
	var arp := [0, 4, 7, 12, 7, 4, 9, 7]
	for bar in bars:
		var root: int = roots[bar]
		var bar_start := int(bar * 4.0 * beat * rate)
		var pad_n := int(4.0 * beat * rate)
		var f1 := 261.63 * pow(2.0, (root - 12) / 12.0)
		for i in pad_n:
			var tt := float(i) / rate
			var e := sin(PI * float(i) / pad_n)
			buf[bar_start + i] += (sin(TAU * f1 * tt) + sin(TAU * f1 * 1.5 * tt) * 0.6) * 0.06 * e
		for k in 8:
			var note: int = root + arp[k]
			var f := 261.63 * pow(2.0, note / 12.0)
			var start := bar_start + int(k * beat * 0.5 * rate)
			var len := int(0.6 * rate)
			for i in len:
				var idx := (start + i) % total  # wrap so the loop is seamless
				var tt := float(i) / rate
				buf[idx] += sin(TAU * f * tt) * 0.09 * exp(-tt * 4.0) * minf(tt * 200.0, 1.0)
	return _to_stream(buf, rate, true)
