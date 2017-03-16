pragma solidity ^0.4.8;

contract Vote {

    address _creator;
    

//Enumération contenant les différents types de votes possibles
    enum VoteType {VoteCandidat}
 
    struct Candidat{
        address adressCandidat;
        uint number;
        string name;
        uint compteurNbOUI;
    }

    address[] votants; //tableau qui reçoit les adresses des personnes qui auront le droit de voter 
    mapping(address => bool) public HasVoted;


    Candidat[]  public candidats;

//Notre contrat est susceptible de déclencher cet évènement
// avec comme paramètres le résulat du vote
    event endVote(uint number);

    //Pour vérifier que le votant n'a pas déjà voté
    modifier voterMustNotHaveVoted(){
        if (HasVoted[msg.sender] == true) throw;
        _;
    }

    // modifier pour ne pas ajouter 2 fois un même candidat
    modifier candidatMustNotExistYet(){
        for (uint i=0; i<candidats.length; i++)
        {
            if (candidats[i].adressCandidat == msg.sender) throw;
            _;
        }
    }
    
    //Pour vérifier que la personne que l'on veut ajouter n'est pas encore dans la liste des votants
    modifier votantMustNotExistYet(address votant){
        for (uint i=0; i<votants.length; i++)
        {
            if (votants[i] == votant) throw;
            _;
        }
    }
    
    //Pour vérifier que c'est bien le créateur du vote qui appelle une fonction 
    modifier isCreator(){
        if(msg.sender != _creator) throw; 
        _;
    }
    
    //Pour vérifier que la personne qui veut voter est bien dans la liste des votants
    modifier voterMustExist(){
        bool exist = false;
        for (uint i=0; i<votants.length; i++)
        {
            if (votants[i] == msg.sender){
                exist=true;
            }
        }
        if (exist == false) throw;
        _;
    }


//Le constructeur:
    function Vote() {
        _creator = msg.sender; //initalise le créateur du vote
        candidats.push(Candidat({
            adressCandidat: msg.sender,
            number: 0,
            name: "VoteBLANC",
            compteurNbOUI: 0
            }));
    }

//Pour que le créateur du vote ajoute un votant
    function addVotant(address adressVotant) public votantMustNotExistYet(adressVotant) isCreator(){
        votants.push(adressVotant);
    }

//Pour que le créateur du vote ajoute un candidat
    function ajoutCandidat(string name) public candidatMustNotExistYet() isCreator(){
        uint nbcandidat = candidats.length;
        candidats.push(Candidat({
            adressCandidat: msg.sender,
            number: nbcandidat,
            name: name,
            compteurNbOUI: 0
            }));
    }

//La fonction voteCandidat permet de voter pour un numéro parmi la liste des candidats
    function voteCandidat(uint number) public voterMustNotHaveVoted() voterMustExist() {
        if (number >= candidats.length) throw; //On vérifie que le numéro du vote correspond à un candidat de la liste
        Candidat c = candidats[number];
        c.compteurNbOUI += 1;
        HasVoted[msg.sender] = true;
    }

//Permet de trouver quel est le numéro du candidat gagnant
    function findWinner() public constant returns (uint numberWinner){
        uint compteurGagnant = 0;
        uint candidatGagnant = 0;
        for (uint i=0; i<candidats.length; i++) {
            if (candidats[i].compteurNbOUI > compteurGagnant) {
                candidatGagnant = candidats[i].number ;
            }
        }
        endVote(candidatGagnant);
    }
   
//Pour supprimer le contrat 
    function kill() isCreator() {
        suicide(msg.sender);
    }

}