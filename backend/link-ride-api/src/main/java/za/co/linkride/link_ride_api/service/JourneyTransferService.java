package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class JourneyTransferService {

    public int countTransfers(
            List<TransportGraphService.GraphEdge> edgePath) {

        if (edgePath == null || edgePath.isEmpty()) {
            return 0;
        }

        int transferCount = 0;

        Long currentRouteId = null;

        for (TransportGraphService.GraphEdge edge
                : edgePath) {

            /*
             * Explicit walking transfer:
             *
             * Example:
             *
             * Gautrain Station
             * -> WALK
             * -> Metrorail Station
             *
             * This counts as one transfer.
             */
            if (edge.isTransfer()) {

                transferCount++;

                /*
                 * The commuter has left the previous
                 * boarded route.
                 */
                currentRouteId = null;

                continue;
            }

            Long nextRouteId =
                    edge.getRouteId();

            if (nextRouteId == null) {
                continue;
            }

            /*
             * First boarded route is not a transfer.
             */
            if (currentRouteId == null) {

                currentRouteId =
                        nextRouteId;

                continue;
            }

            /*
             * Switching directly from one route
             * to another at the same stop counts
             * as one transfer even if there is no
             * explicit WALK edge.
             */
            if (!currentRouteId.equals(
                    nextRouteId)) {

                transferCount++;
            }

            currentRouteId =
                    nextRouteId;
        }

        return transferCount;
    }
}