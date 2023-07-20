module did_safe::kiosk_rule {
    use std::option::{Self, Option};
    use std::string::{String};

    use sui::transfer_policy::{
        Self as policy,
        TransferPolicy,
        TransferPolicyCap,
        TransferRequest
    };

    use did_safe::did_book::{Self, DIDResolver};

    /// When a TwitterId does not find its Rule<TwitterId>.
    const ERuleNotFound: u64 = 0;
    /// When a TwitterId is not registered.
    const EIdNotRegistered: u64 = 1;

    /// Custom witness-key for the "TwitterId policy".
    struct Rule<phantom TwitterId: drop> has drop {}

    /// Creator action: adds the Rule.
    /// Requires a "TwitterId" witness confirmation on every transfer.
    public fun add<T: key + store, TwitterId: drop>(
        policy: &mut TransferPolicy<T>,
        cap: &TransferPolicyCap<T>
    ) {
        policy::add_rule(Rule<TwitterId> {}, policy, cap, true);
    }

    /// Buyer action: follow the policy.
    /// Present the required "TwitterId" instance to get a receipt.
    public fun prove<T: key + store, TwitterId: drop>(
        twitter_id: String,
        resolver: &DIDResolver,
        policy: &TransferPolicy<T>,
        request: &mut TransferRequest<T>
    ) {
        assert!(policy::has_rule<T, Rule<TwitterId>>(policy), ERuleNotFound);
        let did = did_book::retrive_did_from_twitter_id(resolver, twitter_id);
        assert!(option::is_some(&did), EIdNotRegistered);
        policy::add_receipt(Rule<TwitterId> {}, request)
    }
}
