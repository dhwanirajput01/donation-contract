module MyModule::Donation {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::error;

    /// Error codes
    const E_NOT_OWNER: u64 = 1;
    const E_ZERO_DONATION: u64 = 2;

    /// Struct to track donations
    struct DonationVault has key {
        owner: address,
        total_donations: u64,
        donor_count: u64
    }

    /// Initialize the donation vault for the contract owner
    public fun initialize(owner: &signer) {
        let owner_addr = signer::address_of(owner);
        
        // Create the donation vault
        let vault = DonationVault {
            owner: owner_addr,
            total_donations: 0,
            donor_count: 0
        };
        
        move_to(owner, vault);
    }

    /// Function for users to donate Aptos coins to the vault
    public fun donate(donor: &signer, vault_owner: address, amount: u64) acquires DonationVault {
        // Ensure donation amount is not zero
        assert!(amount > 0, error::invalid_argument(E_ZERO_DONATION));
        
        // Get the vault
        let vault = borrow_global_mut<DonationVault>(vault_owner);
        
        // Transfer coins from donor to vault owner
        let donation = coin::withdraw<AptosCoin>(donor, amount);
        coin::deposit<AptosCoin>(vault_owner, donation);
        
        // Update vault statistics
        vault.total_donations = vault.total_donations + amount;
        vault.donor_count = vault.donor_count + 1;
    }
}
