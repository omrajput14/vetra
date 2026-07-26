# Navigation Graph & User Flows

This document details the user navigation flows for the two primary user personas: **Farmer** and **Veterinarian**.

```mermaid
graph TD
    subgraph Auth Flow
        AUTH001["AUTH001: Splash Screen"] --> AUTH002["AUTH002: Onboarding"]
        AUTH002 --> AUTH003["AUTH003: Login"]
        AUTH002 --> AUTH004["AUTH004: Role Selection"]
        AUTH004 -->|Farmer| FRM001["FRM001: Farmer Dashboard"]
        AUTH004 -->|Vet| VET005["AUTH005: Register Vet Details"]
        VET005 --> VET001["VET001: Vet Dashboard"]
    end

    subgraph Farmer Primary Navigation (5 Destinations)
        FRM001["FRM001: Home (Dashboard)"] <--> FRM002["FRM002: My Animals"]
        FRM001 <--> SHR001["SHR001: Alerts (alerts.html)"]
        FRM001 <--> FRM004["FRM004: Nearby Vets"]
        FRM001 <--> PRF001["PRF001: Profile (profile.html)"]
        
        PRF001 --> PRF002["PRF002: Edit Profile"]
        PRF001 --> SET001["SET001: Account Settings"]
        FRM001 --> SHR002["SHR002: Notifications (Top Bell Icon)"]
        
        FRM002 --> ANM001["ANM001: Add Animal"]
        FRM002 --> ANM003["ANM003: Animal Passport"]
        ANM003 --> MED004["MED004: Vaccination Schedule"]
        ANM003 --> ANM006["ANM006: Animal Timeline"]
        
        FRM001 --> AI001["AI001: Disease Scanner"]
        AI001 --> AI002["AI002: Analyzing Scan"]
        AI002 --> AI003["AI003: Scan Diagnostic Result"]
        AI003 --> DIS002["DIS002: Report Disease"]
    end

    subgraph Veterinarian Primary Navigation (4 Destinations)
        VET002["VET002: Requests (assignment icon)"] <--> VET003["VET003: Cases"]
        VET002 <--> MAP001["MAP001: Map"]
        VET002 <--> PRF003["PRF003: Vet Profile"]

        VET002 --> SHR006["SHR006: Appointment Details"]
        VET003 --> MED007["MED007: Diagnosis Entry"]
        MED007 --> MED001["MED001: Add Prescription"]
        MAP001 --> DIS003["DIS003: Nearby Outbreak Details"]
    end
```

## Navigation Rules Summary

- **Farmer Profile (`PRF001`)**: Destination for the Farmer Bottom Nav Profile tab (`screens/profile/profile.html`).
- **Farmer Alerts (`SHR001`)**: Destination for the Farmer Bottom Nav Alerts tab (`screens/shared/alerts.html`).
- **Notifications (`SHR002`)**: Opened from the bell icon in the top app bar across screens.
