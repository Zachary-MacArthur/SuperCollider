(
SynthDef(\additive, {
	var snd, freqs, n, numPartials;
	numPartials = 60;
	n = (1..numPartials);
	freqs = 60 * n * (1 + (n * n * 0.001)).sqrt;
	freqs = 2 ** freqs.log2.blend(freqs.log2.mean, MouseY.kr(0, 1));
	snd = SinOsc.ar(freqs);
	snd = snd * (log2(n) * \tilt.kr(-3)).dbamp;
	snd = snd * ((1 - log2(n * MouseX.kr(1, 100)).sin.abs) ** 5);
	snd = snd.sum ! 2;
	snd = snd * -10.dbamp;
	Out.ar(\out.kr(0), snd);
}).add;
)

(
Synth(\additive);
)