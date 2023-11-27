module townespace::errors {

    use std::error;
    
    friend townespace::core;
    friend townespace::events;
    friend townespace::mint;

    const E_TYPE_NOT_RECOGNIZED: u64 = 1;
    const E_UNGATED_TRANSFER_DISABLED: u64 = 2;
    const E_TOKEN_NOT_BURNABLE: u64 = 3;
    const E_TOKEN_DOES_NOT_EXIST: u64 = 4;
    const E_NOT_OWNER: u64 = 5;
    const E_RECIPIENT_SHOULD_BE_ACCOUNT: u64 = 6;
    const E_ALREADY_OWNER: u64 = 7;
    const E_NOT_TOWNESPACE: u64 = 8;
    const E_INSUFFICIENT_FUNDS: u64 = 9;
    const E_INTERNAL: u64 = 10;

    public(friend) fun type_not_recognized(): u64 { error::not_implemented(E_TYPE_NOT_RECOGNIZED) }
    public(friend) fun ungated_transfer_disabled(): u64 { error::permission_denied(E_UNGATED_TRANSFER_DISABLED) }
    public(friend) fun token_not_found(): u64 { error::not_found(E_TOKEN_DOES_NOT_EXIST) }
    public(friend) fun is_owner(): u64 {  error::aborted(E_ALREADY_OWNER) }
    public(friend) fun recipient_should_be_account(): u64 {  error::aborted(E_RECIPIENT_SHOULD_BE_ACCOUNT) }
    public(friend) fun not_owner(): u64 { error::aborted(E_NOT_OWNER) }
    public(friend) fun not_townespace(): u64 { error::aborted(E_NOT_TOWNESPACE) }
    public(friend) fun insufficient_funds(): u64 { error::aborted(E_INSUFFICIENT_FUNDS) }
    public(friend) fun mint_info_not_found(): u64 { error::internal(E_INTERNAL) }
}