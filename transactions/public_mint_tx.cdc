import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import EpisodeNFT from "../contracts/EpisodeNFT.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"

transaction(episodeID: String) {
    let signerCapability: Capability<&EpisodeNFT.Collection{EpisodeNFT.EpisodeNFTCollectionPublic}>
    let ownerCollectionRef: &AnyResource{EpisodeNFT.EpisodeNFTCollectionPublic}

    prepare(signer: AuthAccount) {
        if signer.borrow<&EpisodeNFT.Collection>(from: EpisodeNFT.CollectionStoragePath) == nil {
            let collection <- EpisodeNFT.createEmptyCollection()
            signer.save(<-collection, to: EpisodeNFT.CollectionStoragePath)
            signer.link<&EpisodeNFT.Collection{NonFungibleToken.CollectionPublic, EpisodeNFT.EpisodeNFTCollectionPublic}>(EpisodeNFT.CollectionPublicPath, target: EpisodeNFT.CollectionStoragePath)
        }

        let owner = getAccount(0x04)
        self.ownerCollectionRef = owner.getCapability(EpisodeNFT.CollectionPublicPath)
                                    .borrow<&AnyResource{EpisodeNFT.EpisodeNFTCollectionPublic}>()
                                    ?? panic("Can't get the User's collection.")
        self.signerCapability = signer.getCapability<&EpisodeNFT.Collection{EpisodeNFT.EpisodeNFTCollectionPublic}>(EpisodeNFT.CollectionPublicPath)      
    }

    execute {
        self.ownerCollectionRef.buy(collectionCapability: self.signerCapability, episodeID: episodeID)  
        log("Minted NFT")
    }
}