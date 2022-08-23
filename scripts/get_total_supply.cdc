import EpisodeNFT from "../contracts/EpisodeNFT.cdc"

pub fun main(): UInt64 {
    return EpisodeNFT.totalSupply
}