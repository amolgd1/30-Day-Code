// SPDX-License-Identifier: MIT


////**** Write a Solidity function to implement a decentralized social media platform,
//  where users can post and interact with content without relying on a centralized authority.  ****////

pragma solidity ^0.8.19;

contract socialMedia{

    struct Comment{  
        address commenter;
        string content;
    }
    struct Post{
        address creator;
        string content;
        uint256 postingTime;
        bool isPosted;
        uint256 likes;
        Comment[] comments;
        mapping(address=>bool) likedBy;
    }

    mapping(uint=>Post) posts;
    uint256 public postCount;

    event Posted(address creator,string content, uint256 postingTime, bool isPosted);
    event PostLiked(address liker,uint postId,uint likes);
    event PostCommented(address commenter, uint postId, string commentContent);
    event postDeleted(address deleter,uint postId);

    function createPost(string memory _content) public{
        postCount++;
        Post storage post= posts[postCount];
        post.creator= msg.sender;
        post.content= _content;
        post.postingTime= block.timestamp;
        post.isPosted= true;
        post.likes= 0;

        emit Posted(msg.sender, _content, block.timestamp, true);
    }

    function likePost(uint _postId) public{
        require(_postId > 0 && _postId <= postCount,"Post id is not exist");
        require(!posts[_postId].likedBy[msg.sender],"This post is already liked"); 
        posts[_postId].likes++;
        posts[_postId].likedBy[msg.sender] = true;
        emit PostLiked(msg.sender, _postId, posts[_postId].likes);
    }

    function commentPost(uint _postId, string memory _content) public{
        require(_postId > 0 && _postId <= postCount,"Invalid post ID");

        Comment memory newComment;
        newComment.commenter= msg.sender;
        newComment.content= _content;
        
        posts[_postId].comments.push(newComment);
        emit PostCommented(msg.sender, _postId, _content);
    }

    function deletePost(uint _postId) public{
        require(_postId > 0 && _postId <= postCount,"Invalid post Id");
        // Post storage post=posts[_postId]; 
        require(msg.sender == posts[_postId].creator,"user only delete his own posts");
        delete posts[_postId];
        emit postDeleted(msg.sender, _postId);
    }

    function getPost(uint _postId) public view returns(address creator,string memory content,uint postingTime,bool isPosted,uint likes,Comment[] memory comments){
        require(_postId > 0 && _postId <= postCount, "Invalid post ID");
        Post storage post= posts[_postId];
        return
        (post.creator, post.content, post.postingTime, post.isPosted, post.likes, post.comments);
    }

}

