//SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Vote{

    address electionCommission;
    address public winner;

    struct Voter {
     string name;
     uint age;
     uint voterID;
     string gender;
     uint voteCandidateID;
     address voterAddress;
    }

    struct Candidate {
     string name;
     string party;
     string gender;
     uint age;
     uint candidateID;
     address candidateAddress;
     uint votes;
    }

    uint nextVoterID = 1;
    uint nextCandidateID = 1;

    uint startTime;
    uint endTime;

    mapping(uint=>Voter) voterDetails;
    mapping(uint=>Candidate) candidateDetails;
    bool stopVoting;

    constructor(){
        electionCommission = msg.sender;
    }

    modifier onlyCommission(){
        require(electionCommission==msg.sender, "You are not from the Election Commission");
        _;
    }

    function voterRegister(string calldata _name, uint _age, string calldata _gender) external {
        require(msg.sender!=electionCommission, "You are from Election Commission!");
        require(_age>=18, "You are not eligible to vote!");
        require(voterVerification(msg.sender)==true, "Voter already registered!");
        voterDetails[nextVoterID] = Voter(_name, _age, nextVoterID, _gender, 0, msg.sender);
        nextVoterID++;
    }

    function voterVerification(address _person) internal view returns (bool) {
        for(uint i=1; i<nextVoterID; i++){
            if(voterDetails[i].voterAddress==_person){
                return false;
            }
        }
        return true;
    }

    function voterList() public view returns(Voter[] memory){
        Voter[] memory voterArray = new Voter[](nextVoterID - 1);
        for(uint i=1;i<nextVoterID;i++){
             voterArray[i-1]=voterDetails[i];
        }
        return voterArray;
    }

    function candidateRegister(string calldata _name, string calldata _gender, uint _age, string calldata _party) external {
        require(msg.sender!=electionCommission, "You are from Election Commission!");
        require(_age>=18, "You are not eligible to register!");
        require(nextCandidateID<3, "Candidate registration full!");
        require(candidateVerification(msg.sender)==true, "Candidate already registered!");
        candidateDetails[nextCandidateID] = Candidate(_name, _party, _gender, _age, nextCandidateID, msg.sender, 0);
        nextCandidateID++;
    }

    function candidateVerification(address _person) internal view returns(bool){
        for(uint i=1; i<nextCandidateID; i++){
            if(candidateDetails[i].candidateAddress==_person){
                return false;
            }
        }
        return true;
    }

    function candidateList() public view returns(Candidate[] memory){
        Candidate[] memory candidateArray = new Candidate[](nextCandidateID-1);
        for(uint i=1;i<nextCandidateID;i++){
             candidateArray[i-1]=candidateDetails[i];
        }
        return candidateArray;
    }

    function voteTime(uint _duration) external onlyCommission() {
        require(nextVoterID!=1, "Voters have not yet registered!");
        require(nextCandidateID==3, "Candidates have not yet registered!");
        startTime=block.timestamp;
        endTime=startTime+_duration; 
    }

    function votingStatus() public view returns(string memory) {
        if(startTime==0)
        {
            return "Voting has not started!";
        }
        else if(endTime>block.timestamp && stopVoting==false)
        {
            return "Voting in progress!";
        }
        else if(stopVoting==true)
        {
            return "Voting halted due to emergency!";
        }

            return "Voting has ended";
    }

    function vote(uint _voterID, uint _candidateID) external {
        require(voterDetails[_voterID].voterAddress==msg.sender, "You have not registered!");
        require(_candidateID>0 && _candidateID<3, "Candidate ID not valid!");
        require(startTime!=0,"Voting has not started!");
        require(nextCandidateID==3, "Candidates have not yet registered!");
        require(voterDetails[_voterID].voteCandidateID==0, "Voter has already voted!");
        voterDetails[_voterID].voteCandidateID++;
        candidateDetails[_candidateID].votes++;
    }

    function emergency() public onlyCommission() {
        stopVoting=true;
    }

    function endEmergency() public onlyCommission() {
        stopVoting=false;
    }

    function result() external onlyCommission() {
        Candidate storage candidate1 = candidateDetails[1];
        Candidate storage candidate2 = candidateDetails[2];
        if(candidate1.votes>candidate2.votes) 
        {
            winner = candidate1.candidateAddress;
        }
        else 
        {
            winner = candidate2.candidateAddress;
        }

    }
}
