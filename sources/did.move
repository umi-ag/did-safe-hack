module did_safe::did_book {
    use std::string::{Self, String};
    use std::option::{Self, Option};
    use std::vector::{Self};

    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::kiosk::{Kiosk, KioskOwnerCap};
    use sui::object_table::{Self, ObjectTable};
    use sui::table::{Self, Table};

    /// init method
    fun init(ctx: &mut TxContext) {
    }

    struct DIDResolver has key, store {
        id: UID,
        book: IDBook,
        twitter: TwitterRetriver,
    }

    struct IDBook has store {
        identifiers: ObjectTable<address, DIdDocument>,
    }

    struct DIdDocument has key, store {
        id: UID, // DID
        twitter_id: Option<String>,
    }

    struct TwitterRetriver has store {
        id_to_did: Table<String, address>,
    }

    public fun create(
        ctx: &mut TxContext,
    ) {
        let resolver=  DIDResolver {
            id: object::new(ctx),
            book: IDBook {
                identifiers: object_table::new(ctx),
            },
            twitter: TwitterRetriver {
                id_to_did: table::new(ctx),
            },
        };
        transfer::public_share_object(resolver);
    }

    public fun register_twitter_id(
        self: &mut DIDResolver,
        twitter_id: String,
        ctx: &mut TxContext,
    ) {
        let doc = DIdDocument{
            id: object::new(ctx),
            twitter_id: option::some(twitter_id),
        };
        let did = object::uid_to_address(&doc.id);
        object_table::add(&mut self.book.identifiers, did, doc);

        table::add(&mut self.twitter.id_to_did, twitter_id, did);
    }

    public fun retrive_did_from_twitter_id(
        self: &DIDResolver,
        twitter_id: String,
    ): Option<address> {
        if (table::contains(&self.twitter.id_to_did, twitter_id)) {
            let did = table::borrow(&self.twitter.id_to_did, twitter_id);
            option::some(*did)
        } else {
            option::none()
        }
    }
}