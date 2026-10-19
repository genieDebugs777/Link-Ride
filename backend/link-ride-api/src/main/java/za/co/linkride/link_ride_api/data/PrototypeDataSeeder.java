package za.co.linkride.link_ride_api.data;

import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import za.co.linkride.link_ride_api.model.Route;
import za.co.linkride.link_ride_api.model.RouteStop;
import za.co.linkride.link_ride_api.model.Stop;
import za.co.linkride.link_ride_api.model.StopTransfer;
import za.co.linkride.link_ride_api.model.TransportProvider;
import za.co.linkride.link_ride_api.repository.RouteRepository;
import za.co.linkride.link_ride_api.repository.RouteStopRepository;
import za.co.linkride.link_ride_api.repository.StopRepository;
import za.co.linkride.link_ride_api.repository.StopTransferRepository;
import za.co.linkride.link_ride_api.repository.TransportProviderRepository;

@Component
public class PrototypeDataSeeder implements CommandLineRunner {

    private final TransportProviderRepository transportProviderRepository;
    private final RouteRepository routeRepository;
    private final StopRepository stopRepository;
    private final RouteStopRepository routeStopRepository;
    private final StopTransferRepository stopTransferRepository;

    public PrototypeDataSeeder(
            TransportProviderRepository transportProviderRepository,
            RouteRepository routeRepository,
            StopRepository stopRepository,
            RouteStopRepository routeStopRepository,
            StopTransferRepository stopTransferRepository) {

        this.transportProviderRepository = transportProviderRepository;
        this.routeRepository = routeRepository;
        this.stopRepository = stopRepository;
        this.routeStopRepository = routeStopRepository;
        this.stopTransferRepository = stopTransferRepository;
    }

    @Override
    public void run(String... args) {

        // ============================================================
        // TRANSPORT PROVIDERS
        // ============================================================

        TransportProvider gautrain =
                transportProviderRepository
                        .findByProviderName("Gautrain")
                        .orElseGet(() -> {

                            TransportProvider provider =
                                    new TransportProvider(
                                            "Gautrain",
                                            "RAIL",
                                            "ACTIVE"
                                    );

                            System.out.println(
                                    "Link Ride prototype data: Gautrain provider seeded."
                            );

                            return transportProviderRepository.save(provider);
                        });

        TransportProvider areYeng =
                transportProviderRepository
                        .findByProviderName("A Re Yeng")
                        .orElseGet(() -> {

                            TransportProvider provider =
                                    new TransportProvider(
                                            "A Re Yeng",
                                            "BRT",
                                            "ACTIVE"
                                    );

                            System.out.println(
                                    "Link Ride prototype data: A Re Yeng provider seeded."
                            );

                            return transportProviderRepository.save(provider);
                        });

        TransportProvider reaVaya =
                transportProviderRepository
                        .findByProviderName("Rea Vaya")
                        .orElseGet(() -> {

                            TransportProvider provider =
                                    new TransportProvider(
                                            "Rea Vaya",
                                            "BRT",
                                            "ACTIVE"
                                    );

                            System.out.println(
                                    "Link Ride prototype data: Rea Vaya provider seeded."
                            );

                            return transportProviderRepository.save(provider);
                        });

        TransportProvider metrorailGauteng =
                transportProviderRepository
                        .findByProviderName("Metrorail Gauteng")
                        .orElseGet(() -> {

                            TransportProvider provider =
                                    new TransportProvider(
                                            "Metrorail Gauteng",
                                            "COMMUTER_RAIL",
                                            "ACTIVE"
                                    );

                            System.out.println(
                                    "Link Ride prototype data: Metrorail Gauteng provider seeded."
                            );

                            return transportProviderRepository.save(provider);
                        });

        TransportProvider minibusTaxiNetwork =
                transportProviderRepository
                        .findByProviderName("Minibus Taxi Network")
                        .orElseGet(() -> {

                            TransportProvider provider =
                                    new TransportProvider(
                                            "Minibus Taxi Network",
                                            "MINIBUS_TAXI",
                                            "ACTIVE"
                                    );

                            System.out.println(
                                    "Link Ride prototype data: Minibus Taxi Network provider seeded."
                            );

                            return transportProviderRepository.save(provider);
                        });

        // ============================================================
        // GAUTRAIN ROUTE
        // ============================================================

        if (routeRepository
                .findByRouteName("Gautrain North-South Prototype")
                .isEmpty()) {

            Route northSouthRoute = new Route(
                    gautrain.getProviderId(),
                    "Gautrain North-South Prototype",
                    "TRAIN",
                    "ACTIVE"
            );

            routeRepository.save(northSouthRoute);

            System.out.println(
                    "Link Ride prototype data: Gautrain North-South route seeded."
            );
        }

        // ============================================================
        // A RE YENG ROUTES
        // ============================================================

        seedRoute(
                areYeng.getProviderId(),
                "Line 1A",
                "BUS"
        );

        seedRoute(
                areYeng.getProviderId(),
                "Line 1A - C02",
                "BUS"
        );

        seedRoute(
                areYeng.getProviderId(),
                "Line 2A",
                "BUS"
        );

        seedRoute(
                areYeng.getProviderId(),
                "Line 2A - F05",
                "BUS"
        );

        seedRoute(
                areYeng.getProviderId(),
                "Line 2A - F07",
                "BUS"
        );

        // ============================================================
        // REA VAYA ROUTE
        // ============================================================

        seedRoute(
                reaVaya.getProviderId(),
                "T3",
                "BUS"
        );

        // ============================================================
        // METRORAIL GAUTENG ROUTE
        // ============================================================

        seedRoute(
                metrorailGauteng.getProviderId(),
                "Pretoria - Saulsville",
                "TRAIN"
        );

        // ============================================================
        // MINIBUS TAXI ROUTES
        // ============================================================

        seedRoute(
                minibusTaxiNetwork.getProviderId(),
                "Mphalane - Pretoria CBD",
                "TAXI"
        );

        seedRoute(
                minibusTaxiNetwork.getProviderId(),
                "Baragwanath - MTN Noord",
                "TAXI"
        );

        // ============================================================
        // GAUTRAIN STOPS
        // ============================================================

        if (stopRepository
                .findByStopName("Hatfield Gautrain Station")
                .isEmpty()) {

            Stop hatfield = new Stop(
                    "Hatfield Gautrain Station",
                    -25.747650,
                    28.238000,
                    "STATION",
                    "ACTIVE"
            );

            stopRepository.save(hatfield);

            System.out.println(
                    "Link Ride prototype data: Hatfield Gautrain Station seeded."
            );
        }

        if (stopRepository
                .findByStopName("Pretoria Gautrain Station")
                .isEmpty()) {

            Stop pretoria = new Stop(
                    "Pretoria Gautrain Station",
                    -25.758167,
                    28.189467,
                    "STATION",
                    "ACTIVE"
            );

            stopRepository.save(pretoria);

            System.out.println(
                    "Link Ride prototype data: Pretoria Gautrain Station seeded."
            );
        }

        if (stopRepository
                .findByStopName("Centurion Gautrain Station")
                .isEmpty()) {

            Stop centurion = new Stop(
                    "Centurion Gautrain Station",
                    -25.851617,
                    28.189733,
                    "STATION",
                    "ACTIVE"
            );

            stopRepository.save(centurion);

            System.out.println(
                    "Link Ride prototype data: Centurion Gautrain Station seeded."
            );
        }

        if (stopRepository
                .findByStopName("Midrand Gautrain Station")
                .isEmpty()) {

            Stop midrand = new Stop(
                    "Midrand Gautrain Station",
                    -25.996483,
                    28.137583,
                    "STATION",
                    "ACTIVE"
            );

            stopRepository.save(midrand);

            System.out.println(
                    "Link Ride prototype data: Midrand Gautrain Station seeded."
            );
        }

        if (stopRepository
                .findByStopName("Sandton Gautrain Station")
                .isEmpty()) {

            Stop sandton = new Stop(
                    "Sandton Gautrain Station",
                    -26.107800,
                    28.057500,
                    "STATION",
                    "ACTIVE"
            );

            stopRepository.save(sandton);

            System.out.println(
                    "Link Ride prototype data: Sandton Gautrain Station seeded."
            );
        }

        if (stopRepository
                .findByStopName("Rosebank Gautrain Station")
                .isEmpty()) {

            Stop rosebank = new Stop(
                    "Rosebank Gautrain Station",
                    -26.145250,
                    28.043867,
                    "STATION",
                    "ACTIVE"
            );

            stopRepository.save(rosebank);

            System.out.println(
                    "Link Ride prototype data: Rosebank Gautrain Station seeded."
            );
        }

        if (stopRepository
                .findByStopName("Park Gautrain Station")
                .isEmpty()) {

            Stop park = new Stop(
                    "Park Gautrain Station",
                    -26.195533,
                    28.041550,
                    "STATION",
                    "ACTIVE"
            );

            stopRepository.save(park);

            System.out.println(
                    "Link Ride prototype data: Park Gautrain Station seeded."
            );
        }

        // ============================================================
        // A RE YENG PHYSICAL STOPS
        // ============================================================

        // ---------------- LINE 1A ----------------

        seedStop(
                "HECTOR PIETERSON",
                -25.681825,
                28.183807,
                "Trunk Route Stop"
        );

        seedStop(
                "PRETORIA STATION",
                -25.756897,
                28.187933,
                "Trunk Route Stop"
        );

        seedStop(
                "LAND AFFAIRS",
                -25.755302,
                28.187223,
                "Trunk Route Stop"
        );

        seedStop(
                "CITY HALL",
                -25.752883,
                28.188488,
                "Trunk Route Stop"
        );

        // ---------------- LINE 1A - C02 ----------------

        // HECTOR PIETERSON is already represented above and is shared.

        seedStop(
                "MIDDLE FRED NICHOLSON EAST",
                -25.707974,
                28.190075,
                "Complementary Stop"
        );

        seedStop(
                "EUGENE MARAIS",
                -25.708440,
                28.194665,
                "Complementary Stop"
        );

        seedStop(
                "BEN SWART",
                -25.714729,
                28.203589,
                "Complementary Stop"
        );

        seedStop(
                "MIDDLE GEZINA SOUTH",
                -25.718922,
                28.204282,
                "Complementary Stop"
        );

        seedStop(
                "UPPER GEZINA SOUTH",
                -25.725341,
                28.205284,
                "Complementary Stop"
        );

        seedStop(
                "SUNNYSIDE",
                -25.750353,
                28.206063,
                "Complementary Stop"
        );

        seedStop(
                "TUT ARCADIA",
                -25.743324,
                28.199654,
                "Complementary Stop"
        );

        seedStop(
                "NELSON MANDELA",
                -25.741491,
                28.200176,
                "Complementary Stop"
        );

        seedStop(
                "STEVE BIKO HOSPITAL",
                -25.731139,
                28.204426,
                "Complementary Stop"
        );

        // ---------------- LINE 2A ----------------

        seedStop(
                "TUKKIES NORTH",
                -25.750759,
                28.231755,
                "Trunk Route Stop"
        );

        seedStop(
                "ARCADIA",
                -25.747723,
                28.233257,
                "Trunk Route Stop"
        );

        seedStop(
                "SIPHO KOMANE",
                -25.750538,
                28.237152,
                "Trunk Route Stop"
        );

        seedStop(
                "TUKKIES SOUTH",
                -25.750915,
                28.232269,
                "Trunk Route Stop"
        );

        // ---------------- LINE 2A - F05 ----------------

        seedStop(
                "VAN LENNEP",
                -25.752456,
                28.196050,
                "Feeder Route Stop"
        );

        seedStop(
                "JUSTICE MAHOMED",
                -25.757064,
                28.202580,
                "Feeder Route Stop"
        );

        seedStop(
                "UNISA SUNNYSIDE",
                -25.757743,
                28.197913,
                "Feeder Route Stop"
        );

        // PRETORIA STATION is already represented above and is shared.

        seedStop(
                "BOSMAN TAXI RANK WEST",
                -25.755676,
                28.184212,
                "Feeder Route Stop"
        );

        seedStop(
                "UPPER KGOSI MAMPURU",
                -25.750174,
                28.180898,
                "Feeder Route Stop"
        );

        seedStop(
                "LOWER KGOSI MAMPURU",
                -25.741258,
                28.179725,
                "Feeder Route Stop"
        );

        seedStop(
                "UPPER MARABASTAD",
                -25.740104,
                28.174021,
                "Feeder Route Stop"
        );

        seedStop(
                "MIDDLE MARABASTAD",
                -25.739911,
                28.176899,
                "Feeder Route Stop"
        );

        seedStop(
                "LOWER MARABASTAD",
                -25.739642,
                28.179767,
                "Feeder Route Stop"
        );

        seedStop(
                "BELLE OMBRE STATION NORTH",
                -25.739435,
                28.182700,
                "Feeder Route Stop"
        );

        seedStop(
                "PRETORIA ZOO",
                -25.739076,
                28.188621,
                "Feeder Route Stop"
        );

        seedStop(
                "TUT ARTS",
                -25.740634,
                28.196227,
                "Feeder Route Stop"
        );

        // This is intentionally a second TUT ARCADIA physical stop.
        seedStop(
                "TUT ARCADIA",
                -25.744853,
                28.200489,
                "Feeder Route Stop"
        );

        // ---------------- LINE 2A - F07 ----------------

        seedStop(
                "MAGNOLIA DAL SOUTH",
                -25.763959,
                28.220581,
                "Feeder Route Stop"
        );

        seedStop(
                "QUINNS",
                -25.767776,
                28.220156,
                "Feeder Route Stop"
        );

        seedStop(
                "STEGER SOUTH",
                -25.770373,
                28.215224,
                "Feeder Route Stop"
        );

        seedStop(
                "TUKS GROENKLOOF NORTH",
                -25.768967,
                28.209774,
                "Feeder Route Stop"
        );

        seedStop(
                "PRELLER WEST",
                -25.767179,
                28.206523,
                "Feeder Route Stop"
        );

        seedStop(
                "SANPARK NORTH",
                -25.765589,
                28.204558,
                "Feeder Route Stop"
        );

        seedStop(
                "UNISA WEST",
                -25.765631,
                28.199450,
                "Feeder Route Stop"
        );

        seedStop(
                "MEARS NORTH",
                -25.761811,
                28.199187,
                "Feeder Route Stop"
        );

        seedStop(
                "WALKER",
                -25.759764,
                28.214418,
                "Feeder Route Stop"
        );

        // ============================================================
        // REA VAYA T3 PHYSICAL STOPS
        // OpenStreetMap-derived coordinates for academic prototype use.
        // ============================================================

        seedStop(
                "Thokoza Park Station",
                -26.26409,
                27.88068,
                "BRT Station"
        );

        seedStop(
                "Lakeview Station",
                -26.26302,
                27.88672,
                "BRT Station"
        );

        seedStop(
                "Klipspruit Valley Station",
                -26.26088,
                27.89080,
                "BRT Station"
        );

        seedStop(
                "Boomtown Station",
                -26.24212,
                27.91544,
                "BRT Station"
        );

        seedStop(
                "Orlando SAPS Station",
                -26.23876,
                27.91984,
                "BRT Station"
        );

        seedStop(
                "Orlando Stadium Station",
                -26.23297,
                27.92409,
                "BRT Station"
        );

        seedStop(
                "Noordgesig Ext. Station",
                -26.22636,
                27.93504,
                "BRT Station"
        );

        seedStop(
                "New Canada Station",
                -26.21581,
                27.94336,
                "BRT Station"
        );

        seedStop(
                "Industria West Station",
                -26.19492,
                27.96299,
                "BRT Station"
        );

        seedStop(
                "Coronationville Station",
                -26.18680,
                27.97613,
                "BRT Station"
        );

        seedStop(
                "Helen Joseph Station",
                -26.18325,
                27.99051,
                "BRT Station"
        );

        seedStop(
                "UJ Kingsway Station",
                -26.18198,
                27.99896,
                "BRT Station"
        );

        seedStop(
                "UJ Sophiatown Station",
                -26.18298,
                28.00357,
                "BRT Station"
        );

        seedStop(
                "SABC Media Park Station",
                -26.18446,
                28.01128,
                "BRT Station"
        );

        seedStop(
                "Milpark Station",
                -26.18316,
                28.02024,
                "BRT Station"
        );

        seedStop(
                "Wits Station",
                -26.18542,
                28.02887,
                "BRT Station"
        );

        seedStop(
                "Parktown Station",
                -26.18524,
                28.03937,
                "BRT Station"
        );

        seedStop(
                "Joburg Theatre Station",
                -26.19164,
                28.03962,
                "BRT Station"
        );

        seedStop(
                "Park Station (Rea Vaya)",
                -26.19567,
                28.04089,
                "BRT Station"
        );

        seedStop(
                "Rissik St. Station",
                -26.20216,
                28.04178,
                "BRT Station"
        );

        seedStop(
                "Library Gardens Station",
                -26.20477,
                28.04164,
                "BRT Station"
        );

        // ============================================================
        // METRORAIL GAUTENG PRETORIA - SAULSVILLE PHYSICAL STOPS
        // OpenStreetMap-derived coordinates for academic prototype use.
        // ============================================================

        seedStop(
                "Pretoria Station",
                -25.75806,
                28.18917,
                "Rail Station"
        );

        seedStop(
                "Pretoria-wes Station",
                -25.75609,
                28.16765,
                "Rail Station"
        );

        seedStop(
                "Rebecca Station",
                -25.75857,
                28.15348,
                "Rail Station"
        );

        seedStop(
                "Elektro Station",
                -25.76131,
                28.14525,
                "Rail Station"
        );

        seedStop(
                "Cor Delfos Station",
                -25.76700,
                28.13321,
                "Rail Station"
        );

        seedStop(
                "Kalafong Station",
                -25.76025,
                28.08845,
                "Rail Station"
        );

        seedStop(
                "Atteridgeville Station",
                -25.76298,
                28.07486,
                "Rail Station"
        );

        seedStop(
                "Saulsville Station",
                -25.76402,
                28.06169,
                "Rail Station"
        );

        // ============================================================
        // MINIBUS TAXI REPRESENTATIVE PHYSICAL NODES
        // Coordinates are from official/municipal sources where available
        // and OpenStreetMap/public-map sources otherwise.
        // Roadside nodes represent corridor pickup areas, not formal stops.
        // ============================================================

        // ---------------- PRETORIA / TSHWANE CORRIDOR ----------------

        seedStop(
                "Mphalane Main Taxi Rank",
                -25.77454,
                28.05191,
                "Taxi Rank"
        );

        seedStop(
                "Westview - Strachan Street Area",
                -25.74874,
                28.11902,
                "Roadside Pickup Area"
        );

        seedStop(
                "Danville - Strachan Street Area",
                -25.73306,
                28.11444,
                "Roadside Pickup Area"
        );

        seedStop(
                "Phillip Nel Park - Sytze Wierda Area",
                -25.738565,
                28.137118,
                "Roadside Pickup Area"
        );

        seedStop(
                "TUT Pretoria West - Technikon Area",
                -25.73154,
                28.16122,
                "Roadside Pickup Area"
        );

        seedStop(
                "Marabastad - Boom Street Area",
                -25.73937,
                28.17351,
                "Taxi Interchange"
        );

        seedStop(
                "Lilian Ngoyi Street - Pretoria CBD",
                -25.74443,
                28.19260,
                "Roadside Pickup Area"
        );

        // ---------------- JOHANNESBURG CORRIDOR ----------------

        seedStop(
                "Bara Taxi Rank",
                -26.25945,
                27.94201,
                "Taxi Rank"
        );

        seedStop(
                "MTN Noord - Park Central Taxi Rank",
                -26.19905,
                28.04769,
                "Taxi Rank"
        );

        // ============================================================
        // GAUTRAIN ROUTE-STOP LINKS
        // ============================================================

        Route northSouth = routeRepository
                .findByRouteName("Gautrain North-South Prototype")
                .orElseThrow(() ->
                        new IllegalStateException(
                                "Gautrain North-South Prototype route not found."
                        )
                );

        Stop hatfieldStop = stopRepository
                .findByStopName("Hatfield Gautrain Station")
                .orElseThrow(() ->
                        new IllegalStateException(
                                "Hatfield Gautrain Station not found."
                        )
                );

        if (routeStopRepository
                .findByRouteIdAndStopOrder(
                        northSouth.getRouteId(),
                        1
                )
                .isEmpty()) {

            RouteStop hatfieldRouteStop = new RouteStop(
                    northSouth.getRouteId(),
                    hatfieldStop.getStopId(),
                    1
            );

            routeStopRepository.save(hatfieldRouteStop);

            System.out.println(
                    "Link Ride prototype data: Hatfield linked to North-South route at order 1."
            );
        }

        Stop pretoriaStop = stopRepository
                .findByStopName("Pretoria Gautrain Station")
                .orElseThrow(() ->
                        new IllegalStateException(
                                "Pretoria Gautrain Station not found."
                        )
                );

        if (routeStopRepository
                .findByRouteIdAndStopOrder(
                        northSouth.getRouteId(),
                        2
                )
                .isEmpty()) {

            RouteStop pretoriaRouteStop = new RouteStop(
                    northSouth.getRouteId(),
                    pretoriaStop.getStopId(),
                    2
            );

            routeStopRepository.save(pretoriaRouteStop);
        }

        Stop centurionStop = stopRepository
                .findByStopName("Centurion Gautrain Station")
                .orElseThrow(() ->
                        new IllegalStateException(
                                "Centurion Gautrain Station not found."
                        )
                );

        if (routeStopRepository
                .findByRouteIdAndStopOrder(
                        northSouth.getRouteId(),
                        3
                )
                .isEmpty()) {

            RouteStop centurionRouteStop = new RouteStop(
                    northSouth.getRouteId(),
                    centurionStop.getStopId(),
                    3
            );

            routeStopRepository.save(centurionRouteStop);
        }

        Stop midrandStop = stopRepository
                .findByStopName("Midrand Gautrain Station")
                .orElseThrow(() ->
                        new IllegalStateException(
                                "Midrand Gautrain Station not found."
                        )
                );

        if (routeStopRepository
                .findByRouteIdAndStopOrder(
                        northSouth.getRouteId(),
                        4
                )
                .isEmpty()) {

            RouteStop midrandRouteStop = new RouteStop(
                    northSouth.getRouteId(),
                    midrandStop.getStopId(),
                    4
            );

            routeStopRepository.save(midrandRouteStop);
        }

        Stop sandtonStop = stopRepository
                .findByStopName("Sandton Gautrain Station")
                .orElseThrow(() ->
                        new IllegalStateException(
                                "Sandton Gautrain Station not found."
                        )
                );

        if (routeStopRepository
                .findByRouteIdAndStopOrder(
                        northSouth.getRouteId(),
                        5
                )
                .isEmpty()) {

            RouteStop sandtonRouteStop = new RouteStop(
                    northSouth.getRouteId(),
                    sandtonStop.getStopId(),
                    5
            );

            routeStopRepository.save(sandtonRouteStop);
        }

        Stop rosebankStop = stopRepository
                .findByStopName("Rosebank Gautrain Station")
                .orElseThrow(() ->
                        new IllegalStateException(
                                "Rosebank Gautrain Station not found."
                        )
                );

        if (routeStopRepository
                .findByRouteIdAndStopOrder(
                        northSouth.getRouteId(),
                        6
                )
                .isEmpty()) {

            RouteStop rosebankRouteStop = new RouteStop(
                    northSouth.getRouteId(),
                    rosebankStop.getStopId(),
                    6
            );

            routeStopRepository.save(rosebankRouteStop);
        }

        Stop parkStop = stopRepository
                .findByStopName("Park Gautrain Station")
                .orElseThrow(() ->
                        new IllegalStateException(
                                "Park Gautrain Station not found."
                        )
                );

        if (routeStopRepository
                .findByRouteIdAndStopOrder(
                        northSouth.getRouteId(),
                        7
                )
                .isEmpty()) {

            RouteStop parkRouteStop = new RouteStop(
                    northSouth.getRouteId(),
                    parkStop.getStopId(),
                    7
            );

            routeStopRepository.save(parkRouteStop);
        }

        // ============================================================
        // A RE YENG ROUTE-STOP LINKS
        // ============================================================

        // ---------------- LINE 1A ----------------
        seedRouteStop("Line 1A", "HECTOR PIETERSON",
                -25.681825, 28.183807, 1);
        seedRouteStop("Line 1A", "PRETORIA STATION",
                -25.756897, 28.187933, 2);
        seedRouteStop("Line 1A", "LAND AFFAIRS",
                -25.755302, 28.187223, 3);
        seedRouteStop("Line 1A", "CITY HALL",
                -25.752883, 28.188488, 4);

        // ---------------- LINE 1A - C02 ----------------
        seedRouteStop("Line 1A - C02", "HECTOR PIETERSON",
                -25.681825, 28.183807, 1);
        seedRouteStop("Line 1A - C02", "MIDDLE FRED NICHOLSON EAST",
                -25.707974, 28.190075, 2);
        seedRouteStop("Line 1A - C02", "EUGENE MARAIS",
                -25.708440, 28.194665, 3);
        seedRouteStop("Line 1A - C02", "BEN SWART",
                -25.714729, 28.203589, 4);
        seedRouteStop("Line 1A - C02", "MIDDLE GEZINA SOUTH",
                -25.718922, 28.204282, 5);
        seedRouteStop("Line 1A - C02", "UPPER GEZINA SOUTH",
                -25.725341, 28.205284, 6);
        seedRouteStop("Line 1A - C02", "SUNNYSIDE",
                -25.750353, 28.206063, 7);
        seedRouteStop("Line 1A - C02", "TUT ARCADIA",
                -25.743324, 28.199654, 8);
        seedRouteStop("Line 1A - C02", "NELSON MANDELA",
                -25.741491, 28.200176, 9);
        seedRouteStop("Line 1A - C02", "STEVE BIKO HOSPITAL",
                -25.731139, 28.204426, 10);

        // ---------------- LINE 2A ----------------
        seedRouteStop("Line 2A", "TUKKIES NORTH",
                -25.750759, 28.231755, 1);
        seedRouteStop("Line 2A", "ARCADIA",
                -25.747723, 28.233257, 2);
        seedRouteStop("Line 2A", "SIPHO KOMANE",
                -25.750538, 28.237152, 3);
        seedRouteStop("Line 2A", "TUKKIES SOUTH",
                -25.750915, 28.232269, 4);

        // ---------------- LINE 2A - F05 ----------------
        seedRouteStop("Line 2A - F05", "VAN LENNEP",
                -25.752456, 28.196050, 1);
        seedRouteStop("Line 2A - F05", "JUSTICE MAHOMED",
                -25.757064, 28.202580, 2);
        seedRouteStop("Line 2A - F05", "UNISA SUNNYSIDE",
                -25.757743, 28.197913, 3);
        seedRouteStop("Line 2A - F05", "PRETORIA STATION",
                -25.756897, 28.187933, 4);
        seedRouteStop("Line 2A - F05", "BOSMAN TAXI RANK WEST",
                -25.755676, 28.184212, 5);
        seedRouteStop("Line 2A - F05", "UPPER KGOSI MAMPURU",
                -25.750174, 28.180898, 6);
        seedRouteStop("Line 2A - F05", "LOWER KGOSI MAMPURU",
                -25.741258, 28.179725, 7);
        seedRouteStop("Line 2A - F05", "UPPER MARABASTAD",
                -25.740104, 28.174021, 8);
        seedRouteStop("Line 2A - F05", "MIDDLE MARABASTAD",
                -25.739911, 28.176899, 9);
        seedRouteStop("Line 2A - F05", "LOWER MARABASTAD",
                -25.739642, 28.179767, 10);
        seedRouteStop("Line 2A - F05", "BELLE OMBRE STATION NORTH",
                -25.739435, 28.182700, 11);
        seedRouteStop("Line 2A - F05", "PRETORIA ZOO",
                -25.739076, 28.188621, 12);
        seedRouteStop("Line 2A - F05", "TUT ARTS",
                -25.740634, 28.196227, 13);
        seedRouteStop("Line 2A - F05", "TUT ARCADIA",
                -25.744853, 28.200489, 14);

        // ---------------- LINE 2A - F07 ----------------
        seedRouteStop("Line 2A - F07", "MAGNOLIA DAL SOUTH",
                -25.763959, 28.220581, 1);
        seedRouteStop("Line 2A - F07", "QUINNS",
                -25.767776, 28.220156, 2);
        seedRouteStop("Line 2A - F07", "STEGER SOUTH",
                -25.770373, 28.215224, 3);
        seedRouteStop("Line 2A - F07", "TUKS GROENKLOOF NORTH",
                -25.768967, 28.209774, 4);
        seedRouteStop("Line 2A - F07", "PRELLER WEST",
                -25.767179, 28.206523, 5);
        seedRouteStop("Line 2A - F07", "SANPARK NORTH",
                -25.765589, 28.204558, 6);
        seedRouteStop("Line 2A - F07", "UNISA WEST",
                -25.765631, 28.199450, 7);
        seedRouteStop("Line 2A - F07", "MEARS NORTH",
                -25.761811, 28.199187, 8);
        seedRouteStop("Line 2A - F07", "WALKER",
                -25.759764, 28.214418, 9);


        // ============================================================
        // REA VAYA T3 ROUTE-STOP LINKS
        // Direction: Thokoza Park -> Library Gardens
        // ============================================================

        seedRouteStop("T3", "Thokoza Park Station",
                -26.26409, 27.88068, 1);

        seedRouteStop("T3", "Lakeview Station",
                -26.26302, 27.88672, 2);

        seedRouteStop("T3", "Klipspruit Valley Station",
                -26.26088, 27.89080, 3);

        seedRouteStop("T3", "Boomtown Station",
                -26.24212, 27.91544, 4);

        seedRouteStop("T3", "Orlando SAPS Station",
                -26.23876, 27.91984, 5);

        seedRouteStop("T3", "Orlando Stadium Station",
                -26.23297, 27.92409, 6);

        seedRouteStop("T3", "Noordgesig Ext. Station",
                -26.22636, 27.93504, 7);

        seedRouteStop("T3", "New Canada Station",
                -26.21581, 27.94336, 8);

        seedRouteStop("T3", "Industria West Station",
                -26.19492, 27.96299, 9);

        seedRouteStop("T3", "Coronationville Station",
                -26.18680, 27.97613, 10);

        seedRouteStop("T3", "Helen Joseph Station",
                -26.18325, 27.99051, 11);

        seedRouteStop("T3", "UJ Kingsway Station",
                -26.18198, 27.99896, 12);

        seedRouteStop("T3", "UJ Sophiatown Station",
                -26.18298, 28.00357, 13);

        seedRouteStop("T3", "SABC Media Park Station",
                -26.18446, 28.01128, 14);

        seedRouteStop("T3", "Milpark Station",
                -26.18316, 28.02024, 15);

        seedRouteStop("T3", "Wits Station",
                -26.18542, 28.02887, 16);

        seedRouteStop("T3", "Parktown Station",
                -26.18524, 28.03937, 17);

        seedRouteStop("T3", "Joburg Theatre Station",
                -26.19164, 28.03962, 18);

        seedRouteStop("T3", "Park Station (Rea Vaya)",
                -26.19567, 28.04089, 19);

        seedRouteStop("T3", "Rissik St. Station",
                -26.20216, 28.04178, 20);

        seedRouteStop("T3", "Library Gardens Station",
                -26.20477, 28.04164, 21);


        // ============================================================
        // METRORAIL GAUTENG PRETORIA - SAULSVILLE ROUTE-STOP LINKS
        // Direction: Pretoria -> Saulsville
        // ============================================================

        seedRouteStop("Pretoria - Saulsville", "Pretoria Station",
                -25.75806, 28.18917, 1);

        seedRouteStop("Pretoria - Saulsville", "Pretoria-wes Station",
                -25.75609, 28.16765, 2);

        seedRouteStop("Pretoria - Saulsville", "Rebecca Station",
                -25.75857, 28.15348, 3);

        seedRouteStop("Pretoria - Saulsville", "Elektro Station",
                -25.76131, 28.14525, 4);

        seedRouteStop("Pretoria - Saulsville", "Cor Delfos Station",
                -25.76700, 28.13321, 5);

        seedRouteStop("Pretoria - Saulsville", "Kalafong Station",
                -25.76025, 28.08845, 6);

        seedRouteStop("Pretoria - Saulsville", "Atteridgeville Station",
                -25.76298, 28.07486, 7);

        seedRouteStop("Pretoria - Saulsville", "Saulsville Station",
                -25.76402, 28.06169, 8);


        // ============================================================
        // MINIBUS TAXI ROUTE-STOP LINKS
        // Semi-flexible corridor model:
        // stored nodes are representative ranks/interchanges/pickup areas.
        // ============================================================

        // ---------------- MPHALANE -> PRETORIA CBD ----------------

        seedRouteStop("Mphalane - Pretoria CBD", "Mphalane Main Taxi Rank",
                -25.77454, 28.05191, 1);

        seedRouteStop("Mphalane - Pretoria CBD", "Westview - Strachan Street Area",
                -25.74874, 28.11902, 2);

        seedRouteStop("Mphalane - Pretoria CBD", "Danville - Strachan Street Area",
                -25.73306, 28.11444, 3);

        seedRouteStop("Mphalane - Pretoria CBD", "Phillip Nel Park - Sytze Wierda Area",
                -25.738565, 28.137118, 4);

        seedRouteStop("Mphalane - Pretoria CBD", "TUT Pretoria West - Technikon Area",
                -25.73154, 28.16122, 5);

        seedRouteStop("Mphalane - Pretoria CBD", "Marabastad - Boom Street Area",
                -25.73937, 28.17351, 6);

        seedRouteStop("Mphalane - Pretoria CBD", "Lilian Ngoyi Street - Pretoria CBD",
                -25.74443, 28.19260, 7);

        // ---------------- BARAGWANATH -> MTN NOORD ----------------

        seedRouteStop("Baragwanath - MTN Noord", "Bara Taxi Rank",
                -26.25945, 27.94201, 1);

        seedRouteStop("Baragwanath - MTN Noord", "MTN Noord - Park Central Taxi Rank",
                -26.19905, 28.04769, 2);


        // ============================================================
        // INTER-PROVIDER WALK TRANSFERS
        // Stored as explicit graph edges between separate physical stops.
        // Distance/duration will be calculated by the journey planner.
        // ============================================================

        // Pretoria Station interchange cluster
        seedStopTransfer(
                "Pretoria Gautrain Station", -25.758167, 28.189467,
                "Pretoria Station", -25.75806, 28.18917
        );

        seedStopTransfer(
                "Pretoria Station", -25.75806, 28.18917,
                "PRETORIA STATION", -25.756897, 28.187933
        );

        seedStopTransfer(
                "Pretoria Gautrain Station", -25.758167, 28.189467,
                "PRETORIA STATION", -25.756897, 28.187933
        );

        // Pretoria taxi / A Re Yeng interchanges
        seedStopTransfer(
                "Marabastad - Boom Street Area", -25.73937, 28.17351,
                "UPPER MARABASTAD", -25.740104, 28.174021
        );

        seedStopTransfer(
                "Lilian Ngoyi Street - Pretoria CBD", -25.74443, 28.19260,
                "TUT ARTS", -25.740634, 28.196227
        );

        // Johannesburg interchange cluster
        seedStopTransfer(
                "Park Gautrain Station", -26.195533, 28.041550,
                "Park Station (Rea Vaya)", -26.19567, 28.04089
        );

        seedStopTransfer(
                "MTN Noord - Park Central Taxi Rank", -26.19905, 28.04769,
                "Rissik St. Station", -26.20216, 28.04178
        );

        seedStopTransfer(
                "MTN Noord - Park Central Taxi Rank", -26.19905, 28.04769,
                "Park Gautrain Station", -26.195533, 28.041550
        );

    }

    // ================================================================
    // HELPER METHODS
    // ================================================================

    private void seedRoute(
            Long providerId,
            String routeName,
            String transportMode) {

        if (routeRepository
                .findByRouteName(routeName)
                .isEmpty()) {

            Route route = new Route(
                    providerId,
                    routeName,
                    transportMode,
                    "ACTIVE"
            );

            routeRepository.save(route);

            System.out.println(
                    "Link Ride prototype data: " +
                            routeName +
                            " route seeded."
            );
        }
    }

    private Stop seedStop(
            String stopName,
            Double latitude,
            Double longitude,
            String stopType) {

        return stopRepository
                .findByStopNameAndLatitudeAndLongitude(
                        stopName,
                        latitude,
                        longitude
                )
                .orElseGet(() -> {

                    Stop stop = new Stop(
                            stopName,
                            latitude,
                            longitude,
                            stopType,
                            "ACTIVE"
                    );

                    Stop savedStop = stopRepository.save(stop);

                    System.out.println(
                            "Link Ride prototype data: " +
                                    stopName +
                                    " seeded."
                    );

                    return savedStop;
                });
    }

    private void seedRouteStop(
            String routeName,
            String stopName,
            Double latitude,
            Double longitude,
            Integer stopOrder) {

        Route route = routeRepository
                .findByRouteName(routeName)
                .orElseThrow(() ->
                        new IllegalStateException(
                                routeName + " route not found."
                        )
                );

        Stop stop = stopRepository
                .findByStopNameAndLatitudeAndLongitude(
                        stopName,
                        latitude,
                        longitude
                )
                .orElseThrow(() ->
                        new IllegalStateException(
                                stopName + " stop not found at expected coordinates."
                        )
                );

        if (routeStopRepository
                .findByRouteIdAndStopOrder(
                        route.getRouteId(),
                        stopOrder
                )
                .isEmpty()) {

            RouteStop routeStop = new RouteStop(
                    route.getRouteId(),
                    stop.getStopId(),
                    stopOrder
            );

            routeStopRepository.save(routeStop);

            System.out.println(
                    "Link Ride prototype data: " +
                            stopName +
                            " linked to " +
                            routeName +
                            " at order " +
                            stopOrder +
                            "."
            );
        }
    }


    private void seedStopTransfer(
            String stopAName,
            Double stopALatitude,
            Double stopALongitude,
            String stopBName,
            Double stopBLatitude,
            Double stopBLongitude) {

        Stop firstStop = stopRepository
                .findByStopNameAndLatitudeAndLongitude(
                        stopAName,
                        stopALatitude,
                        stopALongitude
                )
                .orElseThrow(() ->
                        new IllegalStateException(
                                stopAName + " stop not found at expected coordinates."
                        )
                );

        Stop secondStop = stopRepository
                .findByStopNameAndLatitudeAndLongitude(
                        stopBName,
                        stopBLatitude,
                        stopBLongitude
                )
                .orElseThrow(() ->
                        new IllegalStateException(
                                stopBName + " stop not found at expected coordinates."
                        )
                );

        Long stopAId = Math.min(
                firstStop.getStopId(),
                secondStop.getStopId()
        );

        Long stopBId = Math.max(
                firstStop.getStopId(),
                secondStop.getStopId()
        );

        if (stopTransferRepository
                .findByStopAIdAndStopBId(
                        stopAId,
                        stopBId
                )
                .isEmpty()) {

            StopTransfer transfer = new StopTransfer(
                    stopAId,
                    stopBId,
                    "WALK",
                    true,
                    "ACTIVE"
            );

            stopTransferRepository.save(transfer);

            System.out.println(
                    "Link Ride prototype data: walk transfer linked between " +
                            stopAName +
                            " and " +
                            stopBName +
                            "."
            );
        }
    }


}
