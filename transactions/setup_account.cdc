import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import EpisodeNFT from "../contracts/EpisodeNFT.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"

/// This transaction is what an account would run
/// to set itself up to receive NFTs

transaction {

    prepare(signer: AuthAccount) {
        // Return early if the account already has a collection
        if signer.borrow<&EpisodeNFT.Collection>(from: EpisodeNFT.CollectionStoragePath) != nil {
            return
        }

        // Create a new empty collection
        let collection <- EpisodeNFT.createEmptyCollection()

        // save it to the account
        signer.save(<-collection, to: EpisodeNFT.CollectionStoragePath)

        // create a public capability for the collection
        signer.link<&{NonFungibleToken.CollectionPublic, EpisodeNFT.EpisodeNFTCollectionPublic, MetadataViews.ResolverCollection}>(
            EpisodeNFT.CollectionPublicPath,
            target: EpisodeNFT.CollectionStoragePath
        )
    }
}