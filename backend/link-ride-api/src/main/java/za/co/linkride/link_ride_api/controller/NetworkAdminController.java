package za.co.linkride.link_ride_api.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import za.co.linkride.link_ride_api.model.Route;
import za.co.linkride.link_ride_api.model.TransportProvider;
import za.co.linkride.link_ride_api.service.NetworkAdminService;

import java.util.List;

@RestController
@RequestMapping("/api/admin/network")
public class NetworkAdminController {

    private final NetworkAdminService networkAdminService;

    public NetworkAdminController(
            NetworkAdminService networkAdminService) {

        this.networkAdminService =
                networkAdminService;
    }

    @GetMapping("/providers")
    public ResponseEntity<List<TransportProvider>>
    getProviders() {

        return ResponseEntity.ok(
                networkAdminService.getProviders()
        );
    }

    @GetMapping("/routes")
    public ResponseEntity<List<Route>>
    getRoutes() {

        return ResponseEntity.ok(
                networkAdminService.getRoutes()
        );
    }
}
