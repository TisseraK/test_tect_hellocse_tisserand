# Météo de sortie

Application Flutter permettant de rechercher une ville, consulter ses prévisions météo sur 7 jours et déterminer si une activité extérieure (balade, course, pique-nique) est recommandée. Données fournies par [Open-Meteo](https://open-meteo.com/) (aucune clé API requise).

> Ce document sert de plan de route avant le développement : il fixe les choix d'architecture et de bibliothèques et le pourquoi de chacun, avant d'écrire la moindre ligne de code fonctionnel. Les sections encore vides (règles météo, limites, IA) seront complétées au fil de l'avancement.

## Sommaire

- [Prérequis](#prérequis)
- [Lancer le projet](#lancer-le-projet)
- [Planning](#planning)
- [Architecture](#architecture)
- [Bibliothèques utilisées et pourquoi](#bibliothèques-utilisées-et-pourquoi)
- [Règles de recommandation météo](#règles-de-recommandation-météo)
- [Tests](#tests)
- [Analyse et formatage](#analyse-et-formatage)
- [Limites connues et compromis](#limites-connues-et-compromis)
- [Outils d'IA utilisés](#outils-dia-utilisés)

## Prérequis

- Flutter `3.44.x`
- Dart `3.12.x`
- Un simulateur/émulateur iOS ou Android, ou un appareil physique

## Lancer le projet

```bash
cp .env.example .env   # uniquement si .env n'existe pas déjà
flutter pub get
flutter run
```

## Planning

Socle obligatoire d'abord, bonus ensuite seulement si le socle est terminé et validé (`flutter analyze` propre, tests verts).

1. **Fondations** — arborescence Clean Architecture, câblage `get_it`, client HTTP partagé, initialisation Hive, gestion d'erreurs réseau commune, configuration d'environnement (`.env` pour les URLs de base des API).
2. **Domaine** — entités (`City`, `DailyForecast`, `Activity`), contrats de repositories, et en premier le use case le plus critique du test : le moteur de recommandation d'activité (pur, sans dépendance Flutter, testable immédiatement).
3. **Recherche de ville** — datasource geocoding, repository, BLoC, écran avec états chargement / erreur / vide / résultats, anti-rebond sur la saisie.
4. **Prévisions météo** — datasource forecast, repository, BLoC, écran détail 7 jours (conditions, min/max, précipitation, vent), thème clair/sombre.
5. **Recommandation d'activité dans l'UI** — sélecteur d'activité sur l'écran détail, badge Recommandée / Possible / Déconseillée par jour, branché sur le use case du domaine.
6. **Favoris** — repository local Hive, BLoC, ajout/retrait depuis l'écran détail, écran/onglet dédié, persistance vérifiée après redémarrage.
7. **Tests obligatoires** — unitaire sur les règles de recommandation, test de datasource avec réseau simulé, widget test sur un écran clé.
8. **Qualité** — `dart format`, `flutter analyze` sans erreur, relecture de la navigation et de la gestion d'erreurs.
9. **README final** — règles météo précises, limites/compromis, section IA.
10. **Bonus** — cache des dernières prévisions consultées (Hive s'y prête directement), lecture hors-ligne des dernières données chargées, animations légères, accessibilité, éventuellement test d'intégration.

## Architecture

**Clean Architecture** en 3 couches, avec **BLoC** pour la gestion d'état côté présentation.

- `data/` — modèles (DTO), sources de données distantes (Open-Meteo) et locale (Hive), et implémentations des repositories. Seule couche qui connaît l'existence du réseau et du stockage.
- `domain/` — entités, contrats de repositories (interfaces) et use cases (logique métier pure, dont le moteur de recommandation d'activité). Ne dépend d'aucun package Flutter ni d'aucune autre couche.
- `presentation/` — écrans, widgets et BLoC/Cubit. Consomme les use cases du domaine et expose des états immuables à l'UI.

**Pourquoi cette architecture :** le sujet demande explicitement une séparation nette entre interface, logique applicative et accès aux données, et des appels API isolés pour pouvoir être remplacés en test. La Clean Architecture rend cette contrainte structurelle plutôt que déclarative : le domaine ne peut pas physiquement dépendre du réseau ou de Flutter (aucun import ne le permet), donc la logique de recommandation reste testable en isolation totale, et n'importe quelle datasource peut être remplacée par un double de test derrière son interface de repository.

**Pourquoi BLoC :** c'est le pattern de gestion d'état le plus directement complémentaire à la Clean Architecture dans l'écosystème Flutter (flux unidirectionnel event → state, states immuables, aucune logique métier dans les widgets). Il a un outillage de test mature (`bloc_test`) qui permet de vérifier des séquences d'états (chargement → erreur/succès) sans monter l'UI, ce qui correspond exactement à l'attendu « widgets peu chargés en logique ».

L'injection de dépendances est faite via `get_it` (service locator), câblée au démarrage de l'application, afin que chaque couche ne dépende que d'abstractions et puisse être testée indépendamment (repositories mockés avec `mocktail`, appels réseau simulés).

Arborescence (socle obligatoire complet : fondations, domaine, recherche, prévisions, recommandation d'activité, favoris) :

```
lib/
  core/
    constants/    # noms des boxes Hive, etc.
    di/           # injection_container.dart — service locator get_it
    env/          # lecture typée des variables du .env
    error/        # exceptions (data) et failures (domaine/présentation)
    network/      # ApiClient, seul point de contact avec http.Client
    storage/      # initialisation Hive
  data/
    models/         # CityModel, DailyForecastModel — DTO + parsing/sérialisation JSON
    datasources/    # City/WeatherRemoteDataSource, FavoritesLocalDataSource — accès isolés
    repositories/   # *RepositoryImpl — mapping + traduction erreurs
  domain/
    entities/     # City, DailyForecast, Activity, RecommendationLevel
    repositories/ # contrats CityRepository, WeatherRepository, FavoritesRepository
    usecases/     # RecommendActivity — moteur de recommandation d'activité
  presentation/
    bloc/
      city_search/     # CitySearchBloc (event/state), anti-rebond + restartable
      weather_detail/  # WeatherDetailBloc — prévisions + recommandations par activité
    cubit/
      favorites/       # FavoritesCubit — état partagé (écran Favoris + bouton favori)
    screens/
      search/          # écran de recherche (chargement/erreur/vide/résultats)
      weather_detail/  # écran détail météo (7 jours, sélecteur d'activité, favori, retry)
      favorites/       # écran Favoris
      home_shell.dart  # onglets Recherche/Favoris (NavigationBar)
    widgets/         # CityListTile, DailyForecastTile, ActivitySelector, RecommendationBadge
    utils/           # mapping code météo WMO -> libellé/icône, formatage date FR
  main.dart       # bootstrap: charge .env, initialise Hive, câble get_it
```

Recherche de ville : l'anti-rebond (400 ms) est géré côté UI (`Timer` sur le `TextField`) plutôt que dans le BLoC, pour garder ce dernier simple — c'est une préoccupation de saisie utilisateur, pas de logique métier. Le `CitySearchBloc` utilise le transformer `restartable()` de `bloc_concurrency` : si une recherche plus récente est déclenchée avant qu'une précédente n'ait répondu, cette dernière est abandonnée, pour éviter qu'une réponse réseau en retard n'écrase un résultat plus récent.

Favoris : `City` porte l'`id` renvoyé par l'API geocoding, utilisé comme clé Hive (plus fiable que les coordonnées en virgule flottante). `FavoritesLocalDataSource` isole l'accès à la box Hive derrière une interface, comme les datasources distantes. `FavoritesCubit` — un `Cubit` plutôt qu'un `Bloc`, car il n'y a que deux opérations simples (charger, basculer), pas de flux d'événements à orchestrer — est enregistré en **singleton** dans `get_it` et fourni **au-dessus du `MaterialApp`** (donc au-dessus de son `Navigator` interne) : c'est un état partagé entre l'écran Favoris et le bouton favori de l'écran détail (poussé par-dessus via `Navigator.push`), qui vit dans une route différente. Un `BlocProvider` scopé à une seule route (comme `CitySearchBloc` ou `WeatherDetailBloc`) ne serait pas visible depuis une autre route poussée sur le même `Navigator` — d'où ce placement volontairement plus haut. `HomeShell` (`IndexedStack` + `NavigationBar`) fournit les deux onglets Recherche/Favoris demandés par le sujet, tous deux capables d'ouvrir la même fiche météo.

Prévisions météo : sélectionner une ville dans les résultats de recherche pousse l'écran détail, qui déclenche le chargement des 7 prochains jours (`daily=weathercode,temperature_2m_max,temperature_2m_min,precipitation_probability_max,windspeed_10m_max&timezone=auto&forecast_days=7`). Chaque jour affiche condition météo, températures min/max, probabilité de précipitation et vent maximal ; l'état d'erreur propose un bouton « Réessayer ». Le thème clair/sombre est géré globalement (`MaterialApp.theme`/`darkTheme`).

Recommandation d'activité : un `SegmentedButton` (Balade/Course/Pique-nique) pilote l'activité sélectionnée. Le `WeatherDetailBloc` reçoit le use case `RecommendActivity` par injection et calcule, à chaque chargement ou changement d'activité, un niveau de recommandation par jour — les widgets ne font jamais eux-mêmes appel au domaine, ils affichent l'état déjà calculé. Les badges Recommandée/Possible/Déconseillée utilisent des couleurs sémantiques fixes (vert/orange/rouge, cf. `RecommendationBadge`), seule exception au principe « aucune couleur codée en dur » car il n'existe pas de rôle succès/avertissement dans un `ColorScheme` Material standard.

Gestion des erreurs : les datasources lèvent des exceptions typées (`ServerException`, `NetworkException`, `CacheException`), que les repositories catchent et traduisent en `Failure` (`ServerFailure`, `NetworkFailure`, `CacheFailure`) consommées par les BLoC — pas d'exception brute qui remonte jusqu'à l'UI.


### Configuration d'environnement (`.env`)

Open-Meteo est une API publique et gratuite, sans clé il n'y a donc aucun secret à protéger dans ce projet, et un `.env` n'apporte ici aucune sécurité supplémentaire. Il est tout de même utilisé pour externaliser les URLs de base des deux endpoints (`geocoding-api.` et `api.open-meteo.com`) hors du code, plutôt que de les coder en dur dans les datasources : c'est la pratique standard pour permettre de changer d'environnement (dev/staging/prod, ou un mock serveur local) sans recompiler, et elle est reprise ici pour la démontrer même si le besoin réel est limité sur ce projet.

- `.env.example` est versionné et documente les clés attendues.
- `.env` (la copie locale) est ignoré par Git par convention, même si son contenu n'est pas sensible ici.

## Bibliothèques utilisées et pourquoi

| Package | Rôle | Pourquoi ce choix |
|---|---|---|
| `flutter_bloc` | Gestion d'état (BLoC/Cubit) côté présentation | Standard mature de l'écosystème pour un flux d'état prévisible et testable, cohérent avec la Clean Architecture retenue |
| `equatable` | Égalité de valeur pour les events/states BLoC | Évite les rebuilds/émissions dupliquées et le boilerplate de `==`/`hashCode` manuels sur des states immuables |
| `get_it` | Injection de dépendances (service locator) | Câblage simple des couches sans dépendre du widget tree, facilement surchargeable en test (mocks) |
| `http` | Appels aux API Open-Meteo (geocoding + forecast) | Le besoin se limite à deux endpoints GET publics sans clé ni intercepteurs ; package officiel de l'équipe Dart, suffisant et léger (pas besoin des fonctionnalités avancées d'un client comme Dio) |
| `flutter_dotenv` | Chargement des URLs de base depuis `.env` | Externalise la configuration d'environnement hors du code plutôt qu'en dur, pratique standard démontrée ici bien qu'aucune valeur ne soit un secret sur ce projet (voir ci-dessus) |
| `bloc_concurrency` | Transformer `restartable()` pour le BLoC de recherche | Package officiel de l'écosystème bloc dédié à ce problème précis (annuler une recherche obsolète au profit de la plus récente), plus fiable qu'une gestion manuelle des races dans le BLoC |
| `hive_ce` / `hive_ce_flutter` | Persistance locale (favoris, cache des prévisions) | Stockage NoSQL embarqué, rapide, sans setup SQL, adapté à de petites structures (liste de villes favorites, prévisions en cache) ; fork activement maintenu du historique `hive` (dernière publication de `hive` en 2022) — préféré pour un projet livré aujourd'hui en Flutter 3.44/Dart 3.12 |
| `mocktail` (dev) | Mocks pour les tests (datasources/repositories) | Permet de mocker les interfaces de repository/datasource sans génération de code, répond directement à l'exigence « appels API isolés afin d'être remplacés lors des tests » |
| `bloc_test` (dev) | Tests des transitions d'état des BLoC | Compagnon officiel de `flutter_bloc`, permet d'asserter des séquences d'états de façon déclarative |

## Règles de recommandation météo

Implémentées dans `domain/usecases/recommend_activity.dart`, logique pure sans dépendance Flutter.

Chaque jour est noté sur 3 critères indépendants, chacun classé Bon / Acceptable / Mauvais selon des seuils propres à l'activité :

- **Température** — moyenne de `temperatureMin`/`temperatureMax` du jour.
- **Précipitation** — probabilité maximale de précipitation (%).
- **Vent** — vitesse de vent maximale (km/h).

Combinaison volontairement simple :

- un seul critère **Mauvais** → **Déconseillée** ;
- les 3 critères **Bons** → **Recommandée** ;
- sinon (aucun mauvais, au moins un acceptable) → **Possible**.

Seuils retenus (Bon / Acceptable, au-delà = Mauvais) :

| Activité | Température (Bon) | Température (Acceptable) | Précipitation (Bon) | Précipitation (Acceptable) | Vent (Bon) | Vent (Acceptable) |
|---|---|---|---|---|---|---|
| Balade | 10–28 °C | 0–35 °C | ≤ 20 % | ≤ 60 % | ≤ 30 km/h | ≤ 50 km/h |
| Course | 5–22 °C | -5–30 °C | ≤ 20 % | ≤ 60 % | ≤ 25 km/h | ≤ 45 km/h |
| Pique-nique | 15–28 °C | 10–33 °C | ≤ 10 % | ≤ 50 % | ≤ 20 km/h | ≤ 35 km/h |

Rationale : la balade tolère un large éventail de conditions (activité mobile, peu sensible à la pluie légère) ; la course est plus sensible aux températures extrêmes (effort physique) ; le pique-nique, activité statique en extérieur, est le plus exigeant sur la pluie et le vent (confort d'installation) tout en préférant des températures chaudes mais non caniculaires. Ces seuils sont un choix assumé et documenté plutôt qu'un modèle météo scientifique — conformément à l'objectif du test.

## Tests

```bash
flutter test
```

Socle obligatoire couvert, plus quelques tests supplémentaires ciblés sur les points les plus
sensibles (traduction d'erreurs, synchronisation d'état partagé) :

| Fichier | Couvre | Type |
|---|---|---|
| `test/domain/usecases/recommend_activity_test.dart` | Règles de recommandation météo (3 activités, cas limites/bornes) | **Unitaire (obligatoire)** |
| `test/data/datasources/city_remote_data_source_test.dart` | Parsing JSON geocoding, succès/vide/erreur serveur/erreur réseau, via `http.testing.MockClient` (aucun appel réseau réel) | **Datasource, réseau simulé (obligatoire)** |
| `test/presentation/screens/weather_detail/weather_detail_screen_test.dart` | Écran détail météo : chargement → résultats, changement d'activité, erreur + retry, bouton favori | **Widget test (obligatoire)** |
| `test/data/repositories/city_repository_impl_test.dart` | Traduction `ServerException`/`NetworkException` → `Failure` | Unitaire (mocktail) |
| `test/presentation/bloc/city_search/city_search_bloc_test.dart` | Séquences d'états du `CitySearchBloc` (succès, vide, erreur, requête vide) | `bloc_test` (mocktail) |
| `test/data/datasources/favorites_local_data_source_test.dart` | Ajout/retrait de favoris et **persistance réelle après fermeture/réouverture de Hive** | Datasource locale (Hive réel, répertoire temporaire) |

Les datasources sont testées via leur point d'isolation documenté : `MockClient` pour le réseau,
Hive pointé vers un répertoire temporaire pour le stockage local — jamais de mock du domaine ou
de logique métier dupliquée dans les tests.

## Analyse et formatage

```bash
dart format .
flutter analyze
```

## Limites connues et compromis

_(à compléter en fin de développement)_

## Outils d'IA utilisés

- **Claude** (Anthropic model Sonnet) — utilisé pour la création du planning de développement (découpage en étapes de ce README) et la formulation des justifications d'architecture et de bibliothèques. L'ensemble des choix a été validé et arbitré par moi ; je suis en mesure d'expliquer et de modifier tout le code livré.
