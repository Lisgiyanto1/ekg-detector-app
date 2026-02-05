import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ekg_detector/features/scan/ekg_repository.dart';
import 'package:flutter_ekg_detector/features/scan/scan_event.dart';
import 'package:flutter_ekg_detector/features/scan/scan_state.dart';

// --- BLOC ---
class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final EkgRepository repository;

  ScanBloc(this.repository) : super(ScanInitial()) {
    on<InitModel>((event, emit) async {
      try {
        await repository.initialize();
        emit(ScanInitial()); // Ready
      } catch (e) {
        emit(ScanError("Gagal memuat model: $e"));
      }
    });

    on<AnalyzeImage>((event, emit) async {
      emit(ScanLoading());
      try {
        final result = await repository.predict(event.imagePath);
        if (result != null) {
          emit(ScanSuccess(result, event.imagePath));
        } else {
          emit(ScanError("Gagal menganalisa gambar"));
        }
      } catch (e) {
        emit(ScanError("Error: $e"));
      }
    });
  }
}
