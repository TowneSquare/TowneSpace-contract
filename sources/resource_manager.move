/*
    Responsible for managing the resources. 
    Modules that are part of the resource can interact with this module 
    to obtain the resource account signer and to keep track of the system addresses.
*/

module townespace::resource_manager {
    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::resource_account;
    use std::signer;

    friend townespace::mint;
    friend townespace::studio;

    //// Stores permission config such as SignerCapability for controlling the resource account.
    struct PermissionConfig has key {
        //// Required to obtain the resource account signer.
        signer_cap: SignerCapability,
        //// Track the resource address created by the module.
        resource_addr: address,
    }

    //// Initialize PermissionConfig to establish control over the resource account.
    //// This function is invoked only when this resource is deployed the first time.
    public(friend) entry fun init(module_signer: &signer) {
        let module_signer_addr = signer::address_of(module_signer);
        let signer_cap = resource_account::retrieve_resource_account_cap(module_signer, module_signer_addr);
        let resource_addr = account::get_signer_capability_address(&signer_cap);
        move_to(
            module_signer, 
            PermissionConfig {
                signer_cap,
                resource_addr
            }
        );
    }

    //// Can be called by friended modules to obtain the resource account signer.
    //// Function will panic if the module is not friended or does not exist.
    public(friend) fun get_signer(module_address: address): signer acquires PermissionConfig {
        let signer_cap = &borrow_global<PermissionConfig>(module_address).signer_cap;
        account::create_signer_with_capability(signer_cap)
    }

    public fun get_resource_address(module_signer: &signer): address acquires PermissionConfig {
        borrow_global<PermissionConfig>(signer::address_of(module_signer)).resource_addr
    }

    #[test_only]
    public fun initialize_for_test(deployer: &signer) {
        let deployer_addr = signer::address_of(deployer);
        if (!exists<PermissionConfig>(deployer_addr)) {
            /// account::create_account_for_test(deployer_addr);
            let signer_cap = account::create_test_signer_cap(deployer_addr);
            let resource_addr = account::get_signer_capability_address(&signer_cap);
            move_to(
                deployer, 
                PermissionConfig {
                    signer_cap: signer_cap,
                    resource_addr: resource_addr
                }
            );
        };
    }

    #[test_only]
    friend townespace::test_utils;
}
