/* 
*
*  This is an example implementation of a Flow Non-Fungible Token
*  It is not part of the official standard but it assumed to be
*  similar to how many NFTs would implement the core functionality.
*
*  This contract does not implement any sophisticated classification
*  system for its NFTs. It defines a simple NFT with minimal metadata.
*   
*/

import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

pub contract EpisodeNFT: NonFungibleToken {

    pub var totalSupply: UInt64

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath

    // Variable size dictionary of Podcast Mints
    access(self) var podcastTotalMints: {String: UInt64}

    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
        pub let id: UInt64
        pub let serial: UInt64

        pub let episodeID: String
        pub let podcastID: String
        pub let name: String
        pub let description: String
        pub let thumbnail: String
        access(self) let royalties: [MetadataViews.Royalty]
        access(self) let metadata: {String: AnyStruct}
    
        init(
            id: UInt64,
            serial: UInt64,
            episodeID: String,
            podcastID: String,
            name: String,
            description: String,
            thumbnail: String,
            royalties: [MetadataViews.Royalty],
            metadata: {String: AnyStruct},
        ) {
            self.id = id
            self.serial = serial
            self.episodeID = episodeID
            self.podcastID = podcastID
            self.name = name
            self.description = description
            self.thumbnail = thumbnail
            self.royalties = royalties
            self.metadata = metadata
        }
    
        pub fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.Royalties>(),
                Type<MetadataViews.Editions>(),
                Type<MetadataViews.ExternalURL>(),
                Type<MetadataViews.NFTCollectionData>(),
                Type<MetadataViews.NFTCollectionDisplay>(),
                Type<MetadataViews.Serial>(),
                Type<MetadataViews.Traits>()
            ]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: self.name,
                        description: "NFT podcast episode for the ".concat(self.description).concat(" podcast"),
                        thumbnail: MetadataViews.HTTPFile(
                            url: self.thumbnail
                        )
                    )
                case Type<MetadataViews.Editions>():
                    // There is no max number of NFTs that can be minted from this contract
                    // so the max edition field value is set to nil
                    let editionInfo = MetadataViews.Edition(name: "Kickback Podcast Episodes", number: self.id, max: nil)
                    let editionList: [MetadataViews.Edition] = [editionInfo]
                    return MetadataViews.Editions(
                        editionList
                    )
                case Type<MetadataViews.Serial>():
                    return MetadataViews.Serial(
                        self.id
                    )
                case Type<MetadataViews.Royalties>():
                    return MetadataViews.Royalties(
                        self.royalties
                    )
                case Type<MetadataViews.ExternalURL>():
                    return MetadataViews.ExternalURL("https://open.kickback.fm/episode/nft/".concat(self.episodeID))
                case Type<MetadataViews.NFTCollectionData>():
                    return MetadataViews.NFTCollectionData(
                        storagePath: EpisodeNFT.CollectionStoragePath,
                        publicPath: EpisodeNFT.CollectionPublicPath,
                        providerPath: /private/EpisodeNFTCollection,
                        publicCollection: Type<&EpisodeNFT.Collection{EpisodeNFT.EpisodeNFTCollectionPublic}>(),
                        publicLinkedType: Type<&EpisodeNFT.Collection{EpisodeNFT.EpisodeNFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(),
                        providerLinkedType: Type<&EpisodeNFT.Collection{EpisodeNFT.EpisodeNFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Provider,MetadataViews.ResolverCollection}>(),
                        createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {
                            return <-EpisodeNFT.createEmptyCollection()
                        })
                    )
                case Type<MetadataViews.NFTCollectionDisplay>():
                    let media = MetadataViews.Media(
                        file: MetadataViews.HTTPFile(
                            url: "https://kickback-photos.s3.amazonaws.com/logo.svg"
                        ),
                        mediaType: "image/svg+xml"
                    )
                    return MetadataViews.NFTCollectionDisplay(
                        name: "Kickback Podcasts Episodes Collection",
                        description: "Welcome to the Kickback Episodes Collection! Collect free listener NFTs to unlock exclusive perks, content, and project allow lists.",
                        externalURL: MetadataViews.ExternalURL("https://open.kickback.fm"),
                        squareImage: MetadataViews.Media(
                                        file: MetadataViews.HTTPFile(
                                            url: "https://kickback-photos.s3.amazonaws.com/logo.png"
                                        ),
                                        mediaType: "image/png"
                                    ),
                        bannerImage: MetadataViews.Media(
                                        file: MetadataViews.HTTPFile(
                                            url: "https://kickback-photos.s3.amazonaws.com/banner.png"
                                        ),
                                         mediaType: "image/png"
                                    ),
                        socials: {
                            "twitter": MetadataViews.ExternalURL("https://twitter.com/viaKickback"),
                            "discord": MetadataViews.ExternalURL("https://discord.com/invite/5BrvrMxaJ2")
                        }
                    )
                case Type<MetadataViews.Royalties>():
                    return MetadataViews.Royalties([])
                case Type<MetadataViews.Serial>():
                    return MetadataViews.Serial(
                        self.serial
                    )
                case Type<MetadataViews.Traits>():
                    let traitsView = MetadataViews.dictToTraits(dict: self.metadata, excludedNames: [])

                    // foo is a trait with its episodeID
                    let episodeIDTrait = MetadataViews.Trait(name: "episodeID", value: self.metadata["episodeID"], displayType: "String", rarity: nil)
                    traitsView.addTrait(episodeIDTrait)

                    // foo is a trait with its episodeID
                    let podcastIDTrait = MetadataViews.Trait(name: "podcastID", value: self.metadata["podcastID"], displayType: "String", rarity: nil)
                    traitsView.addTrait(podcastIDTrait)
                    
                    return traitsView

            }
            return nil
        }
    }

    pub resource interface EpisodeNFTCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowEpisodeNFT(id: UInt64): &EpisodeNFT.NFT? {
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow EpisodeNFT reference: the ID of the returned reference is incorrect"
            }
        }
    }

    pub resource Collection: EpisodeNFTCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init () {
            self.ownedNFTs <- {}
        }

        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // deposit takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @EpisodeNFT.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }
 
        pub fun borrowEpisodeNFT(id: UInt64): &EpisodeNFT.NFT? {
            if self.ownedNFTs[id] != nil {
                // Create an authorized reference to allow downcasting
                let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
                return ref as! &EpisodeNFT.NFT
            }

            return nil
        }

        pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
            let nft = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
            let EpisodeNFT = nft as! &EpisodeNFT.NFT
            return EpisodeNFT as &AnyResource{MetadataViews.Resolver}
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    // public function that anyone can call to create a new empty collection
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    // Resource that an admin or something similar would own to be
    // able to mint new NFTs
    //
    pub resource NFTMinter {

        // mintNFT mints a new NFT with a new ID
        // and deposit it in the recipients collection using their collection reference
        pub fun mintNFT(
            recipient: &{NonFungibleToken.CollectionPublic},
            episodeID: String,
            podcastID: String,
            name: String,
            description: String,
            thumbnail: String,
            royalties: [MetadataViews.Royalty]
        ) {
            let metadata: {String: AnyStruct} = {}
            let currentBlock = getCurrentBlock()
            metadata["mintedBlock"] = currentBlock.height
            metadata["mintedTime"] = currentBlock.timestamp
            metadata["minter"] = recipient.owner!.address
            var serialNFT: UInt64 = 0

            if let serial: UInt64 = EpisodeNFT.podcastTotalMints[podcastID] {
                EpisodeNFT.podcastTotalMints[podcastID] = serial + UInt64(1)
                serialNFT = serial
            } else {
                EpisodeNFT.podcastTotalMints[podcastID] = UInt64(1)
                serialNFT = UInt64(0)
            }

            // create a new NFT
            var newNFT <- create NFT(
                id: EpisodeNFT.totalSupply,
                serial: serialNFT,
                episodeID: episodeID,
                podcastID: podcastID,
                name: name,
                description: description,
                thumbnail: thumbnail,
                royalties: royalties,
                metadata: metadata,
            )

            // deposit it in the recipient's account using their reference
            recipient.deposit(token: <-newNFT)

            EpisodeNFT.totalSupply = EpisodeNFT.totalSupply + UInt64(1)
        }
    }

    init() {
        // Initialize the total supply
        self.totalSupply = 0

        // Set the named paths
        self.CollectionStoragePath = /storage/EpisodeNFTCollection
        self.CollectionPublicPath = /public/EpisodeNFTCollection
        self.MinterStoragePath = /storage/EpisodeNFTMinter

        // Set the podcast map
        self.podcastTotalMints = {}

        // Create a Collection resource and save it to storage
        let collection <- create Collection()
        self.account.save(<-collection, to: self.CollectionStoragePath)

        // create a public capability for the collection
        self.account.link<&EpisodeNFT.Collection{NonFungibleToken.CollectionPublic, EpisodeNFT.EpisodeNFTCollectionPublic, MetadataViews.ResolverCollection}>(
            self.CollectionPublicPath,
            target: self.CollectionStoragePath
        )

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        emit ContractInitialized()
    }
}