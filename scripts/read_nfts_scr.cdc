import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import EpisodeNFT from "../contracts/EpisodeNFT.cdc"

pub fun main(account: Address): [&EpisodeNFT.NFT?] {
    let collection = getAccount(account).getCapability(EpisodeNFT.CollectionPublicPath)
                        .borrow<&AnyResource{NonFungibleToken.CollectionPublic, EpisodeNFT.EpisodeNFTCollectionPublic}>()
                        ?? panic("Can't get the User's collection.")
    let answer: [&EpisodeNFT.NFT?] = []
    let ids = collection.getIDs()
    for id in ids {
        let resolver = collection.borrowViewResolver(id: id)
        answer.append(resolver)
    }
    return answer
}