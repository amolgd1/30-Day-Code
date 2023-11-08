// SPDX-License-Identifier: MIT

////**** Write a Solidity function to implement a decentralized music streaming platform, 
// where users can stream music and earn rewards for creating and sharing playlists. ****////

pragma solidity ^0.8.19;

// Import OpenZeppelin ERC20 contract
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MusicStreamingPlatform {
    // ERC20 token used for rewards
    IERC20 public rewardToken;

    // Struct to represent a song
    struct Song {
        string title;
        address artist;
        string songURI; // Can be an IPFS hash, URL, or any reference to the song
        uint256 playCount;
    }

    // Struct to represent a playlist
    struct Playlist {
        address creator;
        string playlistName;
        mapping(uint256 => Song) songs; // Mapping to store songs within the playlist
        uint256 totalSongs;
    }

    // Mapping to store playlists
    mapping(uint256 => Playlist) public playlists;
    uint256 public playlistId = 0;

    // Mapping to track user's playlists and rewards
    mapping(address => uint256[]) public userPlaylists;
    mapping(address => uint256) public userRewards;

    // Mapping to store songs
    mapping(uint256 => Song) public songs;
    uint256 public songId = 0;

    event PlaylistCreated(uint256 playlistId, address creator, string playlistName);
    event SongCreated(uint256 songId, address creator, string title, string songURI);
    event SongAddedToPlaylist(uint256 playlistId, uint256 songId);
    event SongPlayed(address user, uint256 playlistId, uint256 songIndex);

    constructor(address _rewardToken) {
        rewardToken = IERC20(_rewardToken);
    }

    // Function to create a new playlist
    function createPlaylist(string memory _playlistName) external {
        playlists[playlistId].creator = msg.sender;
        playlists[playlistId].playlistName = _playlistName;
        userPlaylists[msg.sender].push(playlistId);
        userRewards[msg.sender] += 1; // User receives 1 token for creating a playlist
        emit PlaylistCreated(playlistId, msg.sender, _playlistName);
        playlistId++;
    }

    // Function to add a song to a playlist
    function addSongToPlaylist(uint256 _playlistId, uint256 _songId) external {
        Playlist storage playlist = playlists[_playlistId];
        playlist.songs[playlist.totalSongs] = songs[_songId];
        emit SongAddedToPlaylist(_playlistId, _songId);
        playlist.totalSongs++;
    }

    // Function to create a new song
    function createSong(string memory _title, string memory _songURI) external {
        songs[songId] = Song(_title, msg.sender, _songURI, 0);
        songId++;
        emit SongCreated(songId, msg.sender, _title, _songURI);
    }

    // Function to play a song
    function playSong(uint256 _playlistId, uint256 _songIndex) external {
        Playlist storage playlist = playlists[_playlistId];
        Song storage song = playlist.songs[_songIndex];

        userRewards[msg.sender] += 1; // Reward the user for playing the song
        song.playCount++;
        userRewards[song.artist] += 1; // Reward the artist for their song being played
        emit SongPlayed(msg.sender, _playlistId, _songIndex);
    }

    // Function to claim rewards
    function claimRewards(uint amount) external {
        require(userRewards[msg.sender] >= amount ,"You dont have reward to claim");
        uint256 rewardsToClaim = userRewards[msg.sender];
        require(rewardsToClaim > 0, "No rewards to claim");

        userRewards[msg.sender] = 0; // Reset user's rewards
        rewardToken.transfer(msg.sender, rewardsToClaim); // Transfer rewards to the user
    }

    // Function to get total playlists created
    function getTotalPlaylists() external view returns (uint256) {
        return playlistId;
    }

    // Function to get user's playlists
    function getUserPlaylists(address _user) external view returns (uint256[] memory) {
        return userPlaylists[_user];
    }

    // Function to get playlist details
    function getPlaylist(uint256 _playlistId) external view returns (address, string memory, uint256) {
        Playlist storage playlist = playlists[_playlistId];
        return (playlist.creator, playlist.playlistName, playlist.totalSongs);
    }
}
