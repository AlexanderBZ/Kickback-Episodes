import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import EpisodeNFT from "../contracts/EpisodeNFT.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"
import FungibleToken from "../contracts/FungibleToken.cdc"

/// This script uses the NFTMinter resource to mint a new NFT
/// It must be run with the account that has the minter resource
/// stored in /storage/NFTMinter

transaction(
    recipient: Address,
    name: String,
    episodeID: String,
    podcastID: String,
    description: String,
    thumbnail: String, 
    numberOfEditionsToMint: UInt64,
) {

    /// local variable for storing the minter reference
    let admin: &EpisodeNFT.Admin

    /// Reference to the receiver's collection
    let recipientCollectionRef: &{NonFungibleToken.CollectionPublic}

    /// Previous NFT ID before the transaction executes
    let mintingIDBefore: UInt64

    prepare(signer: AuthAccount) {
        self.mintingIDBefore = EpisodeNFT.totalSupply

        // borrow a reference to the NFTMinter resource in storage
        self.admin = signer.borrow<&EpisodeNFT.Admin>(from: EpisodeNFT.AdminStoragePath)
            ?? panic("Account does not store an object at the specified path")

        // Borrow the recipient's public NFT collection reference
        self.recipientCollectionRef = getAccount(recipient)
            .getCapability(EpisodeNFT.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")
    }

    execute {
        // Set episode
        self.admin.setEpisode(episodeID: episodeID, maxEdition: 100, podcastID: podcastID, metadata: {})

        // Mint the NFT and deposit it to the recipient's collection
        self.admin.batchMintNFTs(recipient: self.recipientCollectionRef, name: name, episodeID: episodeID, description: description, thumbnail: thumbnail, numberOfEditionsToMint: numberOfEditionsToMint)

        // Print total NFTs
        log(EpisodeNFT.totalSupply)
    }
}
 