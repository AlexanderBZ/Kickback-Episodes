import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import EpisodeNFT from "../contracts/EpisodeNFT.cdc"

transaction(name: String, description: String, thumbnail: String, episodeID: String, podcastID: String, metadata: {String: String}) {
    let minter: &EpisodeNFT.NFTMinter
        
    prepare(signer: AuthAccount) {  
        if signer.borrow<&EpisodeNFT.Collection>(from: EpisodeNFT.CollectionStoragePath) == nil {
            let collection <- EpisodeNFT.createEmptyCollection()
            signer.save(<-collection, to: EpisodeNFT.CollectionStoragePath)
            signer.link<&EpisodeNFT.Collection{NonFungibleToken.CollectionPublic, EpisodeNFT.EpisodeNFTCollectionPublic}>(EpisodeNFT.CollectionPublicPath, target: EpisodeNFT.CollectionStoragePath)
        }
        self.minter = signer.borrow<&EpisodeNFT.NFTMinter>(from: EpisodeNFT.MinterStoragePath)
                        ?? panic("Could not borrow a reference to the NFT minter")
    }
    
    execute {
        self.minter.mintNFT(
            name: name,
            description: description,
            thumbnail: thumbnail,
            episodeID: episodeID,
            podcastID: podcastID,
            metadata: metadata
        )
        log("Minted an NFT")
    }
}