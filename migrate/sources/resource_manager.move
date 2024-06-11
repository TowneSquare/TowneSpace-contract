/*
    Responsible for managing the resources. 
    Modules that are part of the resource can interact with this module 
    to obtain the resource account signer and to keep track of the system addresses.
*/

module token_migrate::resource_manager {
    use aptos_framework::account::{Self, SignerCapability};
    use std::signer;

    friend token_migrate::token_migrate;

    /// Stores permission config such as SignerCapability for controlling the resource account.
    struct PermissionConfig has key {
        /// Required to obtain the resource account signer.
        signer_cap: SignerCapability,
        /// Track the resource address created by the module.
        resource_addr: address,
    }

    /// Initialize PermissionConfig to establish control over the resource account.
    /// This function is invoked only when this resource is deployed the first time.
    public entry fun initialize(deployer: &signer) {
        if (!exists<PermissionConfig>(signer::address_of(deployer))) {
            let (resource_signer, signer_cap) = account::create_resource_account(deployer, b"migrate_token");
            let resource_addr = signer::address_of(&resource_signer);
            move_to(
                deployer, 
                PermissionConfig {
                    signer_cap: signer_cap,
                    resource_addr: resource_addr
                }
            );
        };
    }

    /// Can be called by friended modules to obtain the resource account signer.
    /// Function will panic if the module is not friended or does not exist.
    public(friend) fun resource_signer(): signer acquires PermissionConfig {
        let signer_cap = &borrow_global<PermissionConfig>(@token_migrate).signer_cap;
        account::create_signer_with_capability(signer_cap)
    }

    #[view]
    public fun resource_address(): address acquires PermissionConfig {
        borrow_global<PermissionConfig>(@token_migrate).resource_addr
    }
}