import 'dart:async';

import 'package:abiaproject/common/theme/app_theme.dart';
import 'package:abiaproject/database/services/poubelle_service.dart';
import 'package:abiaproject/pages/carte_Poubelle_manage/controllers/carte_poubelle_controller.dart';
import 'package:abiaproject/partagés/widgets_partagés/nav_bar_avec_plus.dart';
import 'package:abiaproject/database/login_data_base.dart';
import 'package:abiaproject/database/services/api_register_service.dart';
import 'package:abiaproject/database/services/api_abia_service.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:geocoding/geocoding.dart';

class TrashMapScreen extends StatefulWidget {
  final TrashMapController trashMapController;
  
  const TrashMapScreen({Key? key, required this.trashMapController}) : super(key: key);

  @override
  State<TrashMapScreen> createState() => _TrashMapScreenState();
}

class _TrashMapScreenState extends State<TrashMapScreen> {
 
  // Utilisation du singleton pour éviter que la navBar recharge toujours la map à chaque fois
  final _poubelleService = PoubelleService();
  StreamSubscription? _poubelleSubscription;

  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _loading = true;
  
  // Ajout de poubelle
  bool _isAddingTrashBin = false;  // Mode d'ajout de poubelle
  latlong.LatLng? _newBinPosition;  // Position sélectionnée
  // Variables pour l'infobulle personnalisée
  TrashBin? selectedBin;
  bool showInfoWindow = false;

  // Liste des poubelles 
  final List<TrashBin> trashBins = [
    TrashBin(
      nomPoubelle: 'DS24E',
      latLng: latlong.LatLng(48.8566, 2.3522),
      address: 'Rue Victor Brault',
      status: Status.full,
      fillPercentage: 100.0,
      capaciteTotale: 100.0,
      verrouille: true
      
    ),
    TrashBin(
      nomPoubelle: '32VCS',
      latLng: latlong.LatLng(48.8570, 2.3510), 
      address: 'Rue Wilson',
      status: Status.medium,
      fillPercentage: 55.0,
      capaciteTotale: 100.0,
      verrouille: false
    ),
  ];

  // Couleur de remplissage en fonction du niveau
  Color _getFillLevelColor(Status? level) {
    // Gestion du cas où level est null
    if (level == null) {
      return Colors.grey; // Couleur par défaut si null
    }
    
    switch (level) {
      case Status.empty:
        return Colors.green;
      case Status.medium:
        return Colors.amber;
      case Status.full:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // De même pour la méthode _getFillLevelText
  String _getFillLevelText(Status? level) {
    // Gestion du cas où level est null
    if (level == null) {
      return "Inconnu"; // Texte par défaut si null
    }
    
    switch (level) {
      case Status.empty:
        return "Vide";
      case Status.medium:
        return "À moitié pleine";
      case Status.full:
        return "Pleine";
      default:
        return "Inconnu";
    }
  }
      
    
    //Mettre à jour future du niveau de remplissage
  void updateTrashBinFillLevel(String binId, double fillPercentage) {
    setState(() {
      final index = trashBins.indexWhere((bin) => bin.nomPoubelle == binId);
      if (index != -1) {
        // Remplacez cette poubelle par une nouvelle avec le niveau mis à jour
        Status newLevel = _calculateFillLevel(fillPercentage);
        
        // Dans une implémentation réelle, vous mettriez à jour l'objet TrashBin lui-même
        // Pour l'instant, nous recréons l'objet entier
        TrashBin updatedBin = TrashBin(
          nomPoubelle: trashBins[index].nomPoubelle,
          latLng: trashBins[index].latLng,
          address: trashBins[index].address,
          status: newLevel,
          fillPercentage: fillPercentage,
          capaciteTotale: trashBins[index].capaciteTotale,
          seuilAlerte: trashBins[index].seuilAlerte, 
          verrouille: trashBins[index].verrouille, 
        );
        
        // Mettre à jour la liste
        trashBins[index] = updatedBin;
        
        // Si la poubelle est actuellement sélectionnée, mettre à jour également selectedBin
        if (selectedBin?.nomPoubelle == binId) {
          selectedBin = updatedBin;
        }
      }
    });
  }

  Status _calculateFillLevel(double fillPercentage) {
    if (fillPercentage < 30) {
      return Status.empty;
    } else if (fillPercentage < 70) {
      return Status.medium;
    } else {
      return Status.full;
    }
  }

  // Mettre à jour la localisation précise des poubelles
  Future<void> _updateBinAddress(TrashBin bin) async {
    try {
      // Afficher un indicateur de chargement
      setState(() {
        // On pourrait ajouter un état de chargement ici si nécessaire
        // isLoadingAddress = true;
      });
      
      // Récupérer l'adresse à partir des coordonnées GPS en utilisant geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
        bin.latLng.latitude,
        bin.latLng.longitude
      );
      
      // Vérifier si on a reçu des résultats
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        
        // Créer une adresse formatée
        final String street = place.street ?? '';
        final String thoroughfare = place.thoroughfare ?? '';
        final String subThoroughfare = place.subThoroughfare ?? '';
        final String locality = place.locality ?? '';
        final String subLocality = place.subLocality ?? '';
        final String postalCode = place.postalCode ?? '';
        
        // Formater l'adresse de façon lisible
        String formattedAddress = '';
        
        if (street.isNotEmpty) {
          formattedAddress = street;
        } else if (thoroughfare.isNotEmpty) {
          formattedAddress = thoroughfare;
          if (subThoroughfare.isNotEmpty) {
            formattedAddress = '$subThoroughfare $formattedAddress';
          }
        }
        
        if (locality.isNotEmpty) {
          if (formattedAddress.isNotEmpty) {
            formattedAddress += ', $locality';
          } else {
            formattedAddress = locality;
          }
        } else if (subLocality.isNotEmpty) {
          if (formattedAddress.isNotEmpty) {
            formattedAddress += ', $subLocality';
          } else {
            formattedAddress = subLocality;
          }
        }
        
        if (postalCode.isNotEmpty) {
          formattedAddress += ' $postalCode';
        }
        
        // Si l'adresse est vide, utiliser une valeur par défaut
        if (formattedAddress.isEmpty) {
          formattedAddress = 'Adresse non disponible';
        }
        
        // Mettre à jour la liste de poubelles avec la nouvelle adresse
        setState(() {
          final index = trashBins.indexWhere((element) => element.nomPoubelle == bin.nomPoubelle);
          if (index != -1) {
            // Créer une nouvelle instance avec l'adresse mise à jour
            TrashBin updatedBin = TrashBin(
              nomPoubelle: bin.nomPoubelle,
              latLng: bin.latLng,
              address: formattedAddress, // Nouvelle adresse
              status: bin.status,
              fillPercentage: bin.fillPercentage,
              capaciteTotale: bin.capaciteTotale,
              seuilAlerte: bin.seuilAlerte,
              verrouille: bin.verrouille,
            );
            
            // Mettre à jour la poubelle dans la liste
            trashBins[index] = updatedBin;
            
            // Si c'est la poubelle sélectionnée, mettre à jour selectedBin
            if (selectedBin?.nomPoubelle == bin.nomPoubelle) {
              selectedBin = updatedBin;
            }
          }
          
          // Terminer le chargement
          // isLoadingAddress = false;
        });
        
        print("Adresse mise à jour pour la poubelle ${bin.nomPoubelle}: $formattedAddress");
      } else {
        print("Aucune information d'adresse trouvée pour les coordonnées: ${bin.latLng}");
      }
    } catch (e) {
      // Gérer les erreurs
      print("Erreur lors de la récupération de l'adresse: $e");
      setState(() {
        // isLoadingAddress = false;
      });
    }
  }
    
  // À appeler lorsqu'une poubelle est sélectionnée
  void _onBinSelected(TrashBin bin) {
    setState(() {
      selectedBin = bin;
      showInfoWindow = true;
    });
    
    // Mettre à jour l'adresse basée sur la position
    _updateBinAddress(bin);
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si les services de localisation sont activés
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _loading = false);
      return;
    }

    // Vérifier les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _loading = false);
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      setState(() => _loading = false);
      return;
    }

    // Obtenir la position actuelle
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }
  
  // Afficher le formulaire d'ajout de poubelle
  void _showAddTrashBinForm(BuildContext context, latlong.LatLng position) {
    // Contrôleurs pour les champs de formulaire
    final capaciteController = TextEditingController(text: '100.0');
    final adresseController = TextEditingController();
    
    // Valeurs par défaut
    Status statutInitial = Status.empty;
    
    // Récupérer l'adresse à partir des coordonnées
    _getAddressFromCoordinates(position).then((address) {
      if (address.isNotEmpty) {
        adresseController.text = address;
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16, right: 16, top: 16
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ajouter une nouvelle poubelle',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25),
              
              // Capacité totale
              TextField(
                controller: capaciteController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Capacité totale (litres)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              
              // Statut initial
              DropdownButtonFormField<Status>(
                value: statutInitial,
                decoration: InputDecoration(
                  labelText: 'Statut initial',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: Status.empty, child: Text('Vide')),
                  DropdownMenuItem(value: Status.medium, child: Text('À moitié pleine')),
                  DropdownMenuItem(value: Status.full, child: Text('Pleine')),
                ],
                onChanged: (value) {
                  statutInitial = value!;
                },
              ),
              SizedBox(height: 16),
              
              // Adresse
              TextField(
                controller: adresseController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              
              // Boutons d'action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Bouton Annuler
                  ElevatedButton(
                    onPressed: () {
                      // Annuler l'ajout
                      setState(() {
                        _isAddingTrashBin = false;
                        _newBinPosition = null;
                      });
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      backgroundColor: const Color.fromARGB(62, 230, 230, 230).withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text('Annuler'),
                  ),



                  // Bouton Ajouter
                  ElevatedButton(
                    onPressed: () {
                      // Valider et ajouter la poubelle
                    _addNewTrashBin(
                      position: position,
                      capacite: double.tryParse(capaciteController.text) ?? 100.0,
                      statut: _convertStatusToString(statutInitial),  // Convertir l'enum en string
                      adresse: adresseController.text,
                      nom: 'BIN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}', // Générer un nom
                    );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text('Ajouter'),
                    
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );

}

  // Ajouter cette fonction où c'est approprié
  String _convertStatusToString(Status status) {
    switch (status) {
      case Status.empty: 
        return 'VIDE';
      case Status.medium: 
        return 'A_MOITIE_PLEINE';
      case Status.full: 
        return 'PLEINE';
      default:
        return 'VIDE';
    }
  }
    
  // Méthode pour récupérer l'adresse à partir des coordonnées
  Future<String> _getAddressFromCoordinates(latlong.LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Récupérer les composants d'adresse
        final String street = place.street ?? '';
        final String thoroughfare = place.thoroughfare ?? '';
        final String subThoroughfare = place.subThoroughfare ?? '';
        final String locality = place.locality ?? '';
        final String subLocality = place.subLocality ?? '';
        final String postalCode = place.postalCode ?? '';
        
        // Formater l'adresse de façon lisible (même logique que dans _updateBinAddress)
        String formattedAddress = '';
        
        if (street.isNotEmpty) {
          formattedAddress = street;
        } else if (thoroughfare.isNotEmpty) {
          formattedAddress = thoroughfare;
          if (subThoroughfare.isNotEmpty) {
            formattedAddress = '$subThoroughfare $formattedAddress';
          }
        }
              if (locality.isNotEmpty) {
          if (formattedAddress.isNotEmpty) {
            formattedAddress += ', $locality';
          } else {
            formattedAddress = locality;
          }
        } else if (subLocality.isNotEmpty) {
          if (formattedAddress.isNotEmpty) {
            formattedAddress += ', $subLocality';
          } else {
            formattedAddress = subLocality;
          }
        }
        
        if (postalCode.isNotEmpty) {
          formattedAddress += ' $postalCode';
        }
        
        // Si l'adresse est vide, utiliser une valeur par défaut
        if (formattedAddress.isEmpty) {
          formattedAddress = 'Adresse non disponible';
        }
        return formattedAddress;
      }
    } catch (e) {
      print("Erreur de géocodage: $e");
    }
    return '';
  }

  // Méthode pour ajouter effectivement la poubelle en utilisant la procédure stockée
  Future<void> _addNewTrashBin({
    required latlong.LatLng position,
    required double capacite,
    required String statut,
    required String adresse,
    required String nom,
  }) async {
    try {
      // Appel à l'API au lieu de la connexion directe à la base de données
      final result = await ApiService.creerPoubelle(
        capacite: capacite,
        statut: statut,
        latitude: position.latitude,
        longitude: position.longitude,
        adresse: adresse,
        nom: nom
      );
      
      // Traitement de la réponse
      if (result['success'] == true) {
        // Création d'une nouvelle poubelle dans l'interface
        setState(() {
          // Ajouter la poubelle à votre liste (selon votre modèle de données)
          trashBins.add(TrashBin(  
            nomPoubelle: nom,     
            latLng: position,    
            address: adresse,
            status: statut == 'VIDE' ? Status.empty : (statut == 'PLEINE' ? Status.full : Status.medium),
            fillPercentage: statut == 'VIDE' ? 10.0 : (statut == 'PLEINE' ? 90.0 : 50.0),
            capaciteTotale: capacite, // Utilisez capaciteTotale au lieu de capacity
            seuilAlerte: 0.9,
            verrouille: true,
          ));
          
          // Réinitialiser les états de l'interface si nécessaire
          _isAddingTrashBin = false;
          _newBinPosition = null;
        });
        // Message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Poubelle ajoutée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(result['message'] ?? 'Erreur inconnue');
      }
    } catch (e) {
      print('Erreur lors de l\'ajout de la poubelle: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
    
  void _updateTrashBins(Map<String, PoubelleInfo> poubelleData) {
    setState(() {
      // Pour chaque poubelle mise à jour
      poubelleData.forEach((id, poubelleInfo) {
        final index = trashBins.indexWhere((bin) => bin.nomPoubelle == id);
        
        if (index != -1) {
          // Calculer le nouveau statut
          Status newStatus = _calculateFillLevel(poubelleInfo.niveauRemplissage);
          
          // Mise à jour de la poubelle
          TrashBin updatedBin = TrashBin(
            nomPoubelle: trashBins[index].nomPoubelle,
            latLng: trashBins[index].latLng,
            address: trashBins[index].address,
            status: newStatus,
            fillPercentage: poubelleInfo.niveauRemplissage,
            capaciteTotale: trashBins[index].capaciteTotale,
            seuilAlerte: trashBins[index].seuilAlerte,
            verrouille: trashBins[index].verrouille,
          );
          
          trashBins[index] = updatedBin;
          
          // Mise à jour de la sélection si nécessaire
          if (selectedBin?.nomPoubelle == id) {
            selectedBin = updatedBin;
          }
        }
      });
    });
  }
  

  // Initialisation de l'état
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    // Utiliser les poubelles déjà chargées ou les charger si c'est la première fois
    _initTrashBins();
  

      // S'abonner aux mises à jour des poubelles
    _poubelleSubscription = _poubelleService.poubelleStream.listen(_updateTrashBins);
  
  }

Future<void> _initTrashBins() async {
  // Si les données sont déjà en cache, les utiliser
  if (_poubelleService.initialLoadDone) {
    setState(() {
      trashBins.clear();
      trashBins.addAll(_poubelleService.cachedTrashBins);
      print('${trashBins.length} poubelles chargées depuis le cache');
    });
    
    // Force une mise à jour immédiate depuis l'API après chargement initial
    try {
      final poubelleData = await _poubelleService.getLatestData();
      _updateTrashBins(poubelleData);
    } catch (e) {
      print('Erreur lors de la mise à jour immédiate : $e');
    }
  } else {
    // Sinon, déclencher le chargement
    final loadedBins = await _poubelleService.loadTrashBinsIfNeeded();
    setState(() {
      trashBins.clear();
      trashBins.addAll(loadedBins);
    });
  }
}

/*
  Future<void> _loadTrashBins() async {
    try {
      print('Chargement des poubelles depuis l\'API...');
      final binData = await ApiService.getAllTrashBins();
      print('Données reçues: ${binData.length} poubelles');
      print('Données brutes: $binData');
      
      setState(() {
        trashBins.clear();
        
        int counter = 0;
        for (var binJson in binData) {
          try {
            print('Traitement de la poubelle ${counter}: ${binJson['nomPoubelle']}');
            final bin = TrashBin.fromJson(binJson);
            trashBins.add(bin);
            print('Poubelle ${counter} ajoutée: ${bin.nomPoubelle} à ${bin.latLng}');
            counter++;
          } catch (e) {
            print('Erreur lors du traitement de la poubelle $counter: $e');
          }
        }
        
        print('${trashBins.length} poubelles chargées depuis la base de données');
      });
    } catch (e) {
      print('Erreur lors du chargement des poubelles: $e');
    }
  }
*/ 

  @override
  void dispose() {
    // Se désabonner uniquement du stream, mais ne pas arrêter le service
    _poubelleSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Utilisez un Scaffold comme conteneur principal
    return Scaffold(
      // Le corps contient la carte et tous les éléments superposés
      body: Stack(
        children: [
          // La carte en arrière-plan (couvre tout l'écran)
          
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition != null
                  ? latlong.LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : latlong.LatLng(5.288968, -3.999097), 
              initialZoom: 18,
              onTap: (tapPosition, point) {
                  if (_isAddingTrashBin) {
                    // Mode ajout: placer un marqueur
                    setState(() {
                      _newBinPosition = point;
                      // Si déjà une position sélectionnée, montrer le formulaire d'ajout
                      _showAddTrashBinForm(context, point);
                    });
                  } else {
                    // Mode normal: fermer l'infobulle
                    setState(() {
                      showInfoWindow = false;
                    });
                  }
                },
            ),
            children: [
              // La couche de la carte OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
                tileProvider: NetworkTileProvider(),
                retinaMode: true, 
              ),
              
              // Marqueur de localisation actuelle
              CurrentLocationLayer(
                style: const LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    color: AppColors.primaryColor,
                    child: Icon(
                      Icons.person_pin,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                  accuracyCircleColor: Colors.blue,
                  
                ),
              ),
              
              // Marqueurs des poubelles
              MarkerLayer(
                markers: trashBins.map((bin) {
                  return Marker(
                    width: 40,
                    height: 40,
                    point: bin.latLng,
                    child: GestureDetector(
                      onTap: () {
                        _onBinSelected(bin);
                      },
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.primaryColor,
                        size: 30,
                      ),
                    ),
                  );
                }).toList(),
              ),
              // Marqueur temporaire pour la nouvelle poubelle
            if (_isAddingTrashBin && _newBinPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40,
                    height: 40,
                    point: _newBinPosition!,
                    child: Stack(
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.primaryColor,
                          size: 30,
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
                        
            ],
          ),
          
          // Titre flottant en haut
          Positioned(
            top: 40, // Ajusté pour la zone safe area
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 290,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: const Text(
                  'Carte des poubelles',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 83, 83, 83),
                  ),
                ),
              ),
            ),
          ),
          
        // Infobulle personnalisée
        if (showInfoWindow && selectedBin != null)
          StreamBuilder(
            stream: Stream.periodic(const Duration(milliseconds: 100)),
            builder: (context, _) {
              // Vérification supplémentaire pour s'assurer que selectedBin reste non-null
              if (selectedBin == null) return const SizedBox.shrink();
              
              // Copie locale sécurisée pour éviter les changements pendant l'exécution
              final TrashBin localSelectedBin = selectedBin!;
              
              // S'assurer que fillPercentage est défini (utiliser 0.0 par défaut si null)
              final double fillPercent = localSelectedBin.fillPercentage ?? 0.0;
              
              // Conversion des coordonnées géographiques en coordonnées d'écran
              final pxPoint = _mapController.camera.latLngToScreenPoint(localSelectedBin.latLng);
              
              if (pxPoint == null) return const SizedBox.shrink();
              
              // Calcul des décalages pour positionner l'infobulle au-dessus du marqueur
              final infoWindowWidth = 340.0;
              final infoWindowHeight = 200.0;
              final markerHeight = 35.0; // Hauteur estimée du marqueur
              
              // Position de l'infobulle (centrée horizontalement, au-dessus du marqueur)
              return Positioned(
                left: pxPoint.x - (infoWindowWidth / 2),
                top: pxPoint.y - infoWindowHeight - markerHeight,
                width: infoWindowWidth,
                child: _buildTrashBinInfoWindow(localSelectedBin),
              );  
            },
          ),


          // Bouton d'action flottant
          Positioned(
            bottom: 120, // Ajusté pour être au-dessus de la barre de navigation
            right: 20,
            child: SizedBox(
              width: 60,
              height: 60,
              child: Material(
                color: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    if (_currentPosition != null) {
                      _mapController.move(
                        latlong.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        18,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: const Center(
                    child: Icon(
                      Icons.my_location_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Après le bouton de localisation, ajoutez un second bouton flottant:
          Positioned(
            bottom: 190, // Au-dessus du bouton de localisation
            right: 20,
            child: SizedBox(
              width: 60,
              height: 60,
              child: Material(
                color: AppColors.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
                child: InkWell(
                  onTap: () async {
                    // Afficher un indicateur de chargement
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rafraîchissement des données...')),
                    );
                    
                    try {
                      final data = await _poubelleService.getLatestData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Données mises à jour!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: $e')),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: const Center(
                    child: Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
                    
          // NavBar flottante en bas (par-dessus tout)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: NavBarAvecPlus(
              initialPage: 0, // Icône de carte sélectionnée
              onPageChanged: (index) {

                if (index == 0 && ModalRoute.of(context)?.settings.name == '/home') {
                  return;
                }
                // Logique de navigation entre les différentes pages
                switch (index) {
                  case 0:
                    Navigator.pushReplacementNamed(context, '/home');
                    break;
                  case 1:
                    Navigator.pushReplacementNamed(context, '/dashboard');
                    break;
                  case 3:
                    Navigator.pushReplacementNamed(context, '/collecte');
                    break;
                  case 4:
                    Navigator.pushReplacementNamed(context, '/notifications');
                    break;
                }
              },
              onPlusButtonPressed: () {
                 setState(() {
                  _isAddingTrashBin = true;
                  
                   showDialog(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder: (BuildContext context) {
                      // Disparaît automatiquement après 8 secondes
                      Future.delayed(Duration(seconds: 8), () {
                        Navigator.of(context).pop();
                      });
                      
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 500),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 50 * (1 - value)),
                                child: Container(
                                  width: 300,
                                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primaryColor.withOpacity(0.9),
                                        AppColors.secondaryColor.withOpacity(0.9),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Icône animée
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: TweenAnimationBuilder<double>(
                                          tween: Tween<double>(begin: 0.0, end: 1.0),
                                          duration: Duration(milliseconds: 800),
                                          builder: (context, value, child) {
                                            return Transform.rotate(
                                              angle: value * 6.28,
                                              child: Icon(
                                                Icons.add_location_alt_rounded,
                                                color: Colors.white,
                                                size: 36,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      
                                      // Titre
                                      Text(
                                        'Mode ajout activé',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      
                                      // Message
                                      Text(
                                        'Touchez la carte pour placer une nouvelle poubelle',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      
                                      // Indicateur animé
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          for (int i = 0; i < 3; i++)
                                            TweenAnimationBuilder<double>(
                                              tween: Tween<double>(begin: 0, end: 1),
                                              duration: Duration(milliseconds: 600),
                                              curve: Interval(
                                                i * 0.2, 
                                                0.6 + i * 0.2, 
                                                curve: Curves.easeInOut
                                              ),
                                              builder: (context, value, child) {
                                                return Container(
                                                  width: 8,
                                                  height: 8,
                                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(value * 0.8),
                                                    shape: BoxShape.circle,
                                                  ),
                                                );
                                              },
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      
                      );
                    },
                  );
                });
                              
              },
              useSvgIcons: false, // Set this to true to use SVG icons
              icons: const [
                Symbols.distance_rounded,
                Icons.bar_chart_rounded,
                Icons.add,
                Symbols.delivery_truck_bolt_rounded,
                Symbols.notifications_unread_rounded,
              ],
              colors: const [
                AppColors.primaryColor,
                AppColors.primaryColor,
                AppColors.primaryColor,
                AppColors.primaryColor,
                AppColors.primaryColor,
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la fenêtre d'information pour une poubelle
  Widget _buildTrashBinInfoWindow(TrashBin bin) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(230, 238, 230, 255), // Couleur de fond violette claire
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // En-tête avec icône et texte
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFE1D5FF), // Couleur légèrement plus foncée pour l'en-tête
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Icône dans un cercle
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor, // Couleur violette plus foncée
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Titre de l'infobulle
                Text(
                  "Poubelle: ${bin.nomPoubelle} ",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.secondaryColor, // Texte violet foncé
                  ),
                ),
              ],
            ),
          ),
          // Corps de l'infobulle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),

                // status de la poubelle
                Row(
                  children: [
                    const Text(
                      "Statut : ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A6A6A),
                      ),
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                      shape: BoxShape.circle,
                        color: _getFillLevelColor(bin.status),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getFillLevelText(bin.status),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getFillLevelColor(bin.status),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                  // Taux de remplissage
                Row(
                  children: [
                    const Text(
                      "Taux de remplissage : ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A6A6A),
                      ),
                    ),
                    Text(
                      // Utilisez l'opérateur ?? pour gérer le cas null
                      "${(bin.fillPercentage ?? 0.0).toInt()} %",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getFillLevelColor(bin.status),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Etat de verrouillage
                Row(
                  children: [
                    const Text(
                      "État : ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A6A6A),
                      ),
                    ),
                    Icon(
                      bin.verrouille ? Icons.lock : Icons.lock_open,
                      size: 16,
                      color: bin.verrouille ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      bin.verrouille ? "Verrouillée" : "Déverrouillée",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                                color: bin.verrouille ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Localisation de la poubelle 
                Row(
                  children: [
                    const Text(
                      "Localisation : ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A6A6A),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        bin.address,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF444444),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
  
                // Boutons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showInfoWindow = false;
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text(
                        'Fermer',
                            style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,  // Optionnel: ajuster la taille du texte si nécessaire
                          ),
                        ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        
        ],
      ),
    );
  }

}

// Niveau de remplissage de la poubelle
enum Status { empty, medium, full }

// Classe représentant une poubelle
class TrashBin {
  final String nomPoubelle;
  final latlong.LatLng latLng; 
  final String address;
  final Status status; // Niveau de remplissage de la poubelle
  final double fillPercentage; // Taux de remplissage (0-100%)
  final double capaciteTotale; 
  final double seuilAlerte;
  final bool verrouille; 


  TrashBin({
    required this.nomPoubelle,
    required this.latLng, //Les coordonnées GPS de la poubelle
    required this.address,
    required this.status, 
    this.fillPercentage = 0.0,
    required this.capaciteTotale,
    this.seuilAlerte = 0.9,
    this.verrouille = true,
  
  });

  // Méthode pour convertir le statut en couleur
  factory TrashBin.fromJson(Map<String, dynamic> json) {
    // Gestion du statut (avec valeur par défaut si null)
    Status status = Status.empty;  // Valeur par défaut
    if (json['statut'] != null) {
      switch (json['statut']) {
        case 'VIDE':
          status = Status.empty;
          break;
        case 'A_MOITIE_PLEINE':
          status = Status.medium;
          break;
        case 'PLEINE':
          status = Status.full;
          break;
      }
    }
    
    // Déterminer le taux de remplissage initial basé sur le statut
    double fillPercentage;
    switch (status) {
      case Status.empty:
        fillPercentage = 10.0;
        break;
      case Status.medium:
        fillPercentage = 50.0;
        break;
      case Status.full:
        fillPercentage = 90.0;
        break;
      default:
        fillPercentage = 0.0;
    }
    
    // Gestion des valeurs par défaut pour les autres champs
    double capacite = (json['capaciteTotale'] != null && json['capaciteTotale'] != 0) 
        ? (json['capaciteTotale']).toDouble() 
        : 100.0;
    
    return TrashBin(
      nomPoubelle: json['nomPoubelle'] ?? 'Sans nom',
      latLng: latlong.LatLng(
        json['latitude'] ?? 0.0, 
        json['longitude'] ?? 0.0
      ),
      address: json['address'] ?? 'Adresse inconnue',
      status: status,
      fillPercentage: fillPercentage,
      capaciteTotale: capacite,
      verrouille: json['verrouille'] ?? true,
      seuilAlerte: 0.9,
    );
  }

}
