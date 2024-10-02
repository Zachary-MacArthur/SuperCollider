


(
SynthDef(\additive, {
	var snd, freqs, n, numPartials, dur;
	dur = \dur.kr(1);
	numPartials = 60;
	n = (1..numPartials);
	freqs = XLine.kr(\freq1.kr(60), \freq2.kr(90), dur) * n * (1 + (n * n * 0.001)).sqrt;
	freqs = 2 ** freqs.log2.blend(freqs.log2.mean, MouseY.kr(0, 2) ** 7);
	snd = SinOsc.ar(freqs);
	//tilt
	snd = snd * (log2(n) * \tilt.kr(-3)).dbamp;
	// comb filter
	snd = snd * ((1 - log2(n * MouseX.kr(1, 16)).sin.abs) ** 5);
	snd = snd * ((1 - log2(n * Line.kr(\comb1.kr(1), \comb2.kr(20), dur)).sin.abs) ** 2);
	// odd partials are mids, even sides
	snd = snd[0,2..].sum + [-1, 1] * snd[1,3..].sum;
	snd = snd * -5.dbamp;
	snd = snd.tanh;
	//add safety limiter
	snd = snd * Env.asr(0.001, 1, 0.001).ar(Done.freeSelf, \gate.kr(1));
	Out.ar(\out.kr(0), snd);
}).add;

SynthDef(\clap, {
	var snd;
	snd = RHPF.ar(Hasher.ar(Sweep.ar), 1, 62);
	snd = snd * -20.dbamp;
	snd = snd ! 2;
	snd = snd * Env([1, 10, 3, 1, 0, 9, 7], [-4.01, 0.01, 0.001, 0.01, 1.001, 0.02], -3).ar(Done.freeSelf);
	snd = snd * -30.dbamp;
	Out.ar(\out.kr(0), snd);
}).add;

SynthDef(\fx, {
	var snd;
	snd = In.ar(\out.kr(0), 2);
	snd = (snd * 2).fold2;
	snd = SelectX.ar(ToggleFF.ar(Dust.ar(1)).lag(0.1), [snd, CombC.ar(snd, 1 / 80, 1 / 60, 0.1)]);
	//snd = PitchShift.ar(snd, 0.7, 3.5);
	//limiter
	ReplaceOut.ar(\out.kr(0), snd);
}).add;
)

(
Routine {
	var bpm, beat, tatum;
	var s;
	var paramSetA, paramSetB;
	var paramSets;
	bpm = 160;
	beat = 60 / bpm;
	tatum = beat * 0.25;
	s = Server.default;

	Synth.tail(s, \fx);
	s.sync;

	paramSetA = [freq1: 1040, freq2: 30, comb1: 1, comb2: 200];
	paramSetB = [freq1: 50, freq2: 10, comb1: 10, comb2: 870];
	paramSets = [
		paramSetA,
		paramSetB,
		paramSetA,
		paramSetB,
		[freq1: 10, freq2: 10, comb1: 10, comb2: 10],
		[freq1: 60, freq2: 30, comb1: 2, comb2: 5],
		paramSetA,
		paramSetB
	];

	inf.do {
		paramSets.do { |paramSet|
		20.do {
			var synth, dur;
			dur = tatum * [1, 2.7, 4, 5].choose;
			if (0.98.coin) {
			s.makeBundle(s.latency, {
				synth = Synth(\additive, [dur: dur] ++ paramSet);
			});
			dur.wait;
			s.makeBundle(s.latency, {
				synth.set(\gate, 0);
		});
	} {
		s.makeBundle(s.latency, {
				Synth(\clap);
			});
			dur.wait;
		};
	  };
	};
  };
} .play;
)















