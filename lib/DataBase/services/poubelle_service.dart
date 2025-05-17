import 'dart:async';
import 'package:abiaproject/database/services/api_abia_service.dart';
import 'package:abiaproject/database/services/api_register_service.dart';
import 'package:abiaproject/pages/carte_Poubelle_manage/screens/carte_poubelle_screen.dart';

class PoubelleService {
  static final PoubelleService _instance = PoubelleService._internal();
  
  factory PoubelleService() {
    return _instance;
  }
  
  PoubelleService._internal();
  
  final _abiaApiService = AbiaApiService();
  Timer? _timer;
  
  final _poubelleStreamController = StreamController<Map<String, PoubelleInfo>>.broadcast();
  Stream<Map<String, PoubelleInfo>> get poubelleStream => _poubelleStreamController.stream;

  // Stockage des poubelles chargées depuis la BD
  List<TrashBin> _cachedTrashBins = [];
  bool _initialLoadDone = false;
  
  // Méthode pour accéder aux données en cache
  List<TrashBin> get cachedTrashBins => _cachedTrashBins;
  bool get initialLoadDone => _initialLoadDone;

  // Charge les poubelles depuis la BD une seule fois
  Future<List<TrashBin>> loadTrashBinsIfNeeded() async {
    if (!_initialLoadDone) {
      try {
        print('Chargement initial des poubelles depuis l\'API...');
        final binData = await ApiService.getAllTrashBins();
        print('Données reçues: ${binData.length} poubelles');
        
        _cachedTrashBins = [];
        int counter = 0;
        
        for (var binJson in binData) {
          try {
            print('Traitement de la poubelle ${counter}: ${binJson['nomPoubelle']}');
            final bin = TrashBin.fromJson(binJson);
            _cachedTrashBins.add(bin);
            print('Poubelle ${counter} ajoutée: ${bin.nomPoubelle} à ${bin.latLng}');
            counter++;
          } catch (e) {
            print('Erreur lors du traitement de la poubelle $counter: $e');
          }
        }
        
        _initialLoadDone = true;
        print('${_cachedTrashBins.length} poubelles chargées depuis la base de données');
      } catch (e) {
        print('Erreur lors du chargement des poubelles: $e');
      }
    }
    
    return _cachedTrashBins;
  }

  void startPeriodicUpdates() {
    // Chargement initial des données au démarrage du service
    loadTrashBinsIfNeeded();
    
    // Ensuite, démarrage des mises à jour
    _timer ??= Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        final updatedData = await _abiaApiService.getFillLevelsFromApi();
        _poubelleStreamController.add(updatedData);
      } catch (e) {
        print('Erreur lors de la mise à jour des données: $e');
      }
    });
  }

  void dispose() {
    _timer?.cancel();
    _poubelleStreamController.close();
  }
}