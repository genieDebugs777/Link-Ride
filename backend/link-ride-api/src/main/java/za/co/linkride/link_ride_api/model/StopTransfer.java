package za.co.linkride.link_ride_api.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(
        name = "stop_transfers",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_stop_transfer_pair",
                        columnNames = {"stop_a_id", "stop_b_id"}
                )
        }
)
public class StopTransfer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "stop_transfer_id")
    private Long stopTransferId;

    @Column(name = "stop_a_id", nullable = false)
    private Long stopAId;

    @Column(name = "stop_b_id", nullable = false)
    private Long stopBId;

    @Column(name = "transfer_mode", nullable = false)
    private String transferMode;

    @Column(name = "bidirectional", nullable = false)
    private Boolean bidirectional;

    @Column(name = "transfer_status", nullable = false)
    private String transferStatus;

    public StopTransfer() {
    }

    public StopTransfer(
            Long stopAId,
            Long stopBId,
            String transferMode,
            Boolean bidirectional,
            String transferStatus) {

        this.stopAId = stopAId;
        this.stopBId = stopBId;
        this.transferMode = transferMode;
        this.bidirectional = bidirectional;
        this.transferStatus = transferStatus;
    }

    public Long getStopTransferId() {
        return stopTransferId;
    }

    public void setStopTransferId(Long stopTransferId) {
        this.stopTransferId = stopTransferId;
    }

    public Long getStopAId() {
        return stopAId;
    }

    public void setStopAId(Long stopAId) {
        this.stopAId = stopAId;
    }

    public Long getStopBId() {
        return stopBId;
    }

    public void setStopBId(Long stopBId) {
        this.stopBId = stopBId;
    }

    public String getTransferMode() {
        return transferMode;
    }

    public void setTransferMode(String transferMode) {
        this.transferMode = transferMode;
    }

    public Boolean getBidirectional() {
        return bidirectional;
    }

    public void setBidirectional(Boolean bidirectional) {
        this.bidirectional = bidirectional;
    }

    public String getTransferStatus() {
        return transferStatus;
    }

    public void setTransferStatus(String transferStatus) {
        this.transferStatus = transferStatus;
    }
}
