import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ekg_detector/features/scan/ekg_repository.dart';
import 'package:flutter_ekg_detector/features/scan/savescan_repository.dart';
import 'package:flutter_ekg_detector/features/scan/scan_event.dart';
import 'package:flutter_ekg_detector/features/scan/scan_state.dart';
import 'package:flutter_ekg_detector/features/scan/statistic_service.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final EkgRepository repository;
  final SaveScanRepository historyScan;
  final StatisticsService statisticsService;

  ScanBloc(this.repository, this.historyScan, this.statisticsService)
    : super(ScanInitial()) {
    
    /// INIT MODEL
    on<InitModel>((event, emit) async {
      try {
        await repository.initialize();
        add(LoadStatistics());
      } catch (e) {
        emit(ScanError("Gagal memuat model: $e"));
      }
    });

    /// LOAD STATISTICS
    on<LoadStatistics>((event, emit) async {
      try {
        final scans = await historyScan.getLastWeekScans();
        final percentages = statisticsService.calculateDiseasePercentage(scans);
        emit(ScanStatisticsLoaded(percentages, scans.length));
      } catch (e) {
        emit(ScanError(e.toString()));
      }
    });

    /// ADD RESET EVENT
    on<ResetScan>((event, emit) {
      emit(ScanInitial());
    });

    /// ANALYZE IMAGE
    on<AnalyzeImage>((event, emit) async {
      emit(ScanLoading());

      try {
        final result = await repository.predict(event.imagePath);

        if (result != null) {
          await historyScan.saveScan(
            label: result.label,
            confidence: 1.0,
            urgency: result.urgency,
          );

          final scans = await historyScan.getLastWeekScans();
          final percentages = statisticsService.calculateDiseasePercentage(scans);

          // HANYA pancarkan ScanSuccess di sini. 
          emit(ScanSuccess(result, event.imagePath, percentages));
        } else {
          emit(ScanError("Objek tidak dikenali sebagai grafik EKG."));
        }
      } catch (e) {
        emit(ScanError(e.toString()));
      }
    });
  }
}