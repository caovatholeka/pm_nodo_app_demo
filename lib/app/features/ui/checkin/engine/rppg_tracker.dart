import 'dart:math' as math;
import 'dart:typed_data';

class RppgTracker {
  final int capacity;
  final double fs;
  final _buf = <double>[];

  RppgTracker({this.capacity = 256, this.fs = 30.0});

  void add(double greenMean) {
    _buf.add(greenMean);
    if (_buf.length > capacity) _buf.removeAt(0);
  }

  double? snrDb() {
    if (_buf.length < (fs * 2)) return null;
    final x = _detrend(_buf);
    final bp = _bandpassFIR(x, fs, 0.7, 3.0);
    final y = _hanning(bp);

    final mag = _fftMag(y);
    final freqs = _freqs(mag.length, fs);

    double peak = 0, noise = 0;
    for (int i = 1; i < mag.length ~/ 2; i++) {
      final f = freqs[i];
      if (f >= 0.7 && f <= 3.0) {
        if (mag[i] > peak) peak = mag[i];
      } else if (f > 0.2) {
        noise += mag[i];
      }
    }
    noise = noise / ((mag.length ~/ 2) - 1);
    final snr = 10 * math.log((peak + 1e-9) / (noise + 1e-9)) / math.ln10;
    return snr;
  }

  List<double> _detrend(List<double> x) {
    final n = x.length;
    final mean = x.reduce((a,b)=>a+b) / n;
    return List<double>.generate(n, (i) => x[i] - mean);
  }

  List<double> _hanning(List<double> x) {
    final n = x.length;
    return List<double>.generate(n, (i) => x[i] * (0.5 - 0.5 * math.cos(2*math.pi*i/(n-1))));
  }

  List<double> _bandpassFIR(List<double> x, double fs, double f1, double f2) {
    const taps = 101;
    final h = _bandpassKernel(taps, fs, f1, f2);
    final y = List<double>.filled(x.length, 0);
    for (int n = 0; n < x.length; n++) {
      double s = 0;
      for (int k = 0; k < taps; k++) {
        final idx = n - k;
        if (idx >= 0) s += x[idx] * h[k];
      }
      y[n] = s;
    }
    return y;
  }

  List<double> _bandpassKernel(int m, double fs, double f1, double f2) {
    final w1 = 2*math.pi*f1/fs, w2 = 2*math.pi*f2/fs;
    final h = List<double>.filled(m, 0);
    final mid = (m-1)/2;
    for (int n = 0; n < m; n++) {
      final k = n - mid;
      double hd;
      if (k == 0) hd = (w2 - w1)/math.pi;
      else hd = (math.sin(w2*k) - math.sin(w1*k)) / (math.pi*k);
      final w = 0.54 - 0.46 * math.cos(2*math.pi*n/(m-1)); // Hamming
      h[n] = hd * w;
    }
    return h;
  }

  List<double> _fftMag(List<double> x) {
    int n = 1;
    while (n < x.length) n <<= 1;
    final re = Float64List(n);
    final im = Float64List(n);
    for (int i=0;i<x.length;i++) re[i] = x[i];

    _fft(re, im); // in-place
    final mag = List<double>.generate(n, (i)=> math.sqrt(re[i]*re[i] + im[i]*im[i]));
    return mag;
  }

  void _fft(Float64List re, Float64List im) {
    final n = re.length;
    // bit-reversal
    int j = 0;
    for (int i=1; i<n; i++) {
      int bit = n >> 1;
      for (; (j & bit) != 0; bit >>= 1) { j &= ~bit; }
      j |= bit;
      if (i < j) {
        final tr = re[i]; re[i] = re[j]; re[j] = tr;
        final ti = im[i]; im[i] = im[j]; im[j] = ti;
      }
    }
    for (int len=2; len<=n; len<<=1) {
      final ang = -2*math.pi/len;
      final wlenRe = math.cos(ang), wlenIm = math.sin(ang);
      for (int i=0; i<n; i+=len) {
        double wRe=1, wIm=0;
        for (int k=0;k<len~/2;k++) {
          final uRe = re[i+k], uIm = im[i+k];
          final vRe = re[i+k+len~/2]*wRe - im[i+k+len~/2]*wIm;
          final vIm = re[i+k+len~/2]*wIm + im[i+k+len~/2]*wRe;
          re[i+k] = uRe + vRe;
          im[i+k] = uIm + vIm;
          re[i+k+len~/2] = uRe - vRe;
          im[i+k+len~/2] = uIm - vIm;
          final tRe = wRe*wlenRe - wIm*wlenIm;
          wIm = wRe*wlenIm + wIm*wlenRe;
          wRe = tRe;
        }
      }
    }
  }

  List<double> _freqs(int n, double fs) {
    final out = List<double>.generate(n, (i) => i * fs / n);
    return out;
  }
}
