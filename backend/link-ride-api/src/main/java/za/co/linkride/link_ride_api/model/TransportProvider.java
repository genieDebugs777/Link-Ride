package za.co.linkride.link_ride_api.model;

import jakarta.persistence.*;

@Entity
@Table(name = "transport_providers")
public class TransportProvider {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "provider_id")
    private Long providerId;

    @Column(name = "provider_name", nullable = false)
    private String providerName;

    @Column(name = "provider_type", nullable = false)
    private String providerType;

    @Column(name = "provider_status", nullable = false)
    private String providerStatus;

    public TransportProvider() {
    }

    public TransportProvider(
            String providerName,
            String providerType,
            String providerStatus) {

        this.providerName = providerName;
        this.providerType = providerType;
        this.providerStatus = providerStatus;
    }

    public Long getProviderId() {
        return providerId;
    }

    public void setProviderId(Long providerId) {
        this.providerId = providerId;
    }

    public String getProviderName() {
        return providerName;
    }

    public void setProviderName(String providerName) {
        this.providerName = providerName;
    }

    public String getProviderType() {
        return providerType;
    }

    public void setProviderType(String providerType) {
        this.providerType = providerType;
    }

    public String getProviderStatus() {
        return providerStatus;
    }

    public void setProviderStatus(String providerStatus) {
        this.providerStatus = providerStatus;
    }
}