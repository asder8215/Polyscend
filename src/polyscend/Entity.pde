import java.util.concurrent.ThreadLocalRandom;
// Base Entity class
public abstract class Entity {
    // Attributes common to both Player and Enemy
    protected String name;
    protected int health;
    protected int stamina;
    protected int maxAtkPwr;
    protected int minAtkPwr;
    protected int maxStamina;

    // Constructor for initializing an entity
    public Entity(String name, int health, int stamina, int maxAtkPwr, int minAtkPwr) {
        this.name = name;
        this.health = health;
        this.stamina = stamina;
        this.maxAtkPwr = maxAtkPwr;
        this.minAtkPwr = minAtkPwr;
        this.maxStamina = stamina;
    }

    public abstract String useMove(Entity entity);
    public abstract int takeDamage(int dmg);

    // Getter and Setter methods for name
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    // Getter and Setter methods for health
    public int getHealth() {
        return health;
    }

    public void setHealth(int health) {
        this.health = health;
    }

    // Getter and Setter methods for stamina
    public int getStamina() {
        return stamina;
    }

    public void setStamina(int stamina) {
        this.stamina = stamina;
    }

    public int getMaxStamina() {
        return maxStamina;
    }

    // Getter and Setter methods for health
    public int getMaxAtkPwr() {
        return maxAtkPwr;
    }

    public void setMaxAtkPwr(int maxAtkPwr) {
        this.maxAtkPwr = maxAtkPwr;
    }

    // Getter and Setter methods for health
    public int getMinAtkPwr() {
        return minAtkPwr;
    }

    public void setMinAtkPwr(int minAtkPwr) {
        this.minAtkPwr = minAtkPwr;
    }

    public boolean isAlive(){
        return this.getHealth() > 0;
    }

    // Method to display entity info
    public void displayInfo() {
        System.out.println("Name: " + name);
        System.out.println("Health: " + health);
        System.out.println("Stamina: " + stamina);
    }
}

// Player class inheriting from Entity
public class Player extends Entity {
    // protected boolean vulnerable = false;
    protected boolean guard = false;
    protected int boostMode = 1;
    protected String move = "";
    protected int coolDown = 0;
    protected int runAwayUnsuccessful = 0;
    // Additional player-specific attributes and methods can go here
    public Player(String name, int health, int stamina, int maxAtkPwr, int minAtkPwr) {
        super(name, health, stamina, maxAtkPwr, minAtkPwr);
    }

    // You can add Player-specific methods
    // public void attack() {
    //     System.out.println(name + " attacks with stamina: " + stamina);
    // }

    public void selectMove(String move) {
        this.move = move;
    }

    @Override
    public String useMove(Entity enemy){
        String moveText = "Nothing occurred (also may not be implemented yet)";
        if (this.move.equals("Attack")){
            int dmg = attack();
            int staminaUsed = staminaLoss();
            int dmgDealt = enemy.takeDamage(dmg);
            this.setStamina(Math.max(this.getStamina() - staminaUsed, 0));
            moveText = this.getName() + " dealt " + String.valueOf(dmgDealt) + " damage to " + enemy.getName() + ".";
        }
        else if (this.move.equals("Guard")){
            if (this.getStamina() == 0){
                moveText = this.getName() + " used Guard. It failed!";
            }
            else {
                this.guard = true;
                int staminaUsed = staminaLoss();
                this.setStamina(Math.max(this.getStamina() - staminaUsed, 0));
                moveText = this.getName() + " decided to guard!";
            }
        }
        else if (this.move.equals("Calm Down")){
            if (this.getStamina() == this.getMaxStamina()){
                moveText = this.getName() + " used Calm Down. It failed!";
            }
            else {
                int staminaRestored = this.calmDown();
                this.setStamina(this.getStamina() + staminaRestored);
                // this.vulnerable = true;
                moveText = this.getName() + " cleared his head. Restored " + String.valueOf(staminaRestored) + " stamina.";
            }
        }
        else if (this.move.equals("Run")){
            int rndNum = ThreadLocalRandom.current().nextInt(0, 101);
            int probs = 50/(int) Math.pow(2, runAwayUnsuccessful);

            if (rndNum > probs) {
                this.runAwayUnsuccessful = 0;
                moveText = this.getName() + " ran away from " + enemy.getName() + " successfully!";
            }
            else {
                this.runAwayUnsuccessful += 1;
                moveText = this.getName() + " failed to run away from " + enemy.getName() + ".";
            }
        }
        return moveText;
    }

    public void setBoostMode(int boostMode) {
        this.boostMode = boostMode;
    }

    public boolean isOnCoolDown() {
        if (this.coolDown > 0) {
            this.coolDown--;
            return true;
        }
        return false;
    }

    private int attack() {
        if (this.getStamina() == 0) {
            return 0;
        }
        int randDmg = ThreadLocalRandom.current().nextInt(this.getMinAtkPwr() * this.boostMode, (this.getMaxAtkPwr() + 1) * this.boostMode);
        return randDmg;
    }

    private int staminaLoss(){
        if (this.guard) {
            return 3 * this.boostMode;
        }
        return 5 * this.boostMode;
    }

    private int calmDown(){
        this.coolDown = this.boostMode - 1;
        return 8 * (int) Math.pow(1.75, this.boostMode);
    }
    
    @Override
    public int takeDamage(int dmg){
        int dmgDealt;
        if (this.guard) {
            dmgDealt = dmg/(this.boostMode + 1);
        } 
        else {
            dmgDealt = dmg;
        }
        int dmgGiven = (int) Math.min(this.getHealth(), dmgDealt);
        this.setHealth(Math.max(this.getHealth() - dmgDealt, 0));
        this.guard = false;
        return dmgGiven;
    }

}

// Enemy class inheriting from Entity
public class Square extends Entity {
    // Additional enemy-specific attributes and methods can go here
    private final String[] moveChoices = {"Attack", "Square Up", "Calm Down"};
    private int squareUpStack = 0;
    private boolean squaredUp = false;

    public Square(String name, int health, int stamina, int maxAtkPwr, int minAtkPwr) {
        super(name, health, stamina, maxAtkPwr, minAtkPwr);
    }

    @Override
    public String useMove(Entity player){
        int rndNum = ThreadLocalRandom.current().nextInt(0, 101);
        // int rnd;
        if (this.getStamina() > (this.getMaxStamina() * 0.3)) {
            int probs = 100 - (int) Math.pow(4, squareUpStack + 1) - 10;
            if (rndNum > probs){
                return this.moveEffect(moveChoices[0], player);
            }
            else {
                return this.moveEffect(moveChoices[1], player);
            }
        }
        else if (this.getStamina() > 0) {
            int probs = 33;
            if (rndNum > probs) {
                return this.moveEffect(moveChoices[2], player);
            }
            else if (rndNum > probs - 20) {
                return this.moveEffect(moveChoices[0], player);
            }
            else {
                return this.moveEffect(moveChoices[1], player);
            }
        }
        return this.moveEffect(moveChoices[2], player);
    }

    private String moveEffect(String move, Entity player){
        String moveText = "Nothing occurred";
        if (move.equals("Attack")){
            int dmg = attack();
            int staminaUsed = staminaLoss();
            int dmgDealt = player.takeDamage(dmg);
            this.setStamina(Math.max(this.getStamina() - staminaUsed, 0));
            moveText = this.getName() + " dealt " + String.valueOf(dmgDealt) + " damage to " + player.getName() + ".";
        }
        else if (move.equals("Square Up")){
            if (this.getStamina() == 0){
                moveText = "Square Up failed!";
            }
            else {
                this.squaredUp = true;
                this.squareUpStack += 1;
                int dmgMultiplier = (int) Math.pow(2, this.squareUpStack);
                int staminaUsed = staminaLoss();
                this.setStamina(Math.max(this.getStamina() - staminaUsed, 0));
                moveText = this.getName() + " used Square Up! Its next attack will deal at least " + String.valueOf(dmgMultiplier) + " times more damage.";
            }
        }
        else if (move.equals("Calm Down")){
            if (this.getStamina() == this.getMaxStamina()){
                moveText = this.getName() + " used Calm Down. It failed!";
            }
            int staminaRestored = this.calmDown();
            this.setStamina(this.getStamina() + staminaRestored);
            moveText = this.getName() + " cleared its sides. Restored " + String.valueOf(staminaRestored) + " stamina.";
        }
        return moveText;
    }
    
    private int attack() {
        if (this.getStamina() == 0) {
            return 0;
        }
        int randDmg = ThreadLocalRandom.current().nextInt(this.getMinAtkPwr()  * (int) Math.pow(2, this.squareUpStack), (this.getMaxAtkPwr() + 1)  * (int) Math.pow(2, this.squareUpStack));
        this.squareUpStack = 0;
        return randDmg;
    }

    private int staminaLoss(){
        if (this.squaredUp) {
            this.squaredUp = false;
            return (10 * (squareUpStack))/2 ;
        }
        return 5;
    }

    private int calmDown(){
        return 8;
    }

    @Override
    public int takeDamage(int dmg){
        int dmgDealt = (int) Math.min(this.getHealth(), dmg);
        this.setHealth(Math.max(this.getHealth() - dmg, 0));
        return dmgDealt;
    }
}

// Enemy class inheriting from Entity
public class Circle extends Entity {
    // Additional enemy-specific attributes and methods can go here
    private final String[] moveChoices = {"Attack", "Bounce", "Calm Down"};
    private boolean bounceWait = false;

    public Circle(String name, int health, int stamina, int maxAtkPwr, int minAtkPwr) {
        super(name, health, stamina, maxAtkPwr, minAtkPwr);
    }

    @Override
    public String useMove(Entity player){
        int rndNum = ThreadLocalRandom.current().nextInt(0, 101);
        if (this.bounceWait) {
            return this.moveEffect(moveChoices[1], player);
        }
        else if (this.getStamina() > (this.getMaxStamina() * 0.3)) {
            int probs = 50;
            if (rndNum > probs){
                return this.moveEffect(moveChoices[0], player);
            }
            else {
                return this.moveEffect(moveChoices[1], player);
            }
        }
        else if (this.getStamina() > 0) {
            int probs = 33;
            if (rndNum > probs) {
                return this.moveEffect(moveChoices[2], player);
            }
            else if (rndNum > probs - 20) {
                return this.moveEffect(moveChoices[0], player);
            }
            else {
                return this.moveEffect(moveChoices[1], player);
            }
        }
        return this.moveEffect(moveChoices[2], player);
    }

    private String moveEffect(String move, Entity player){
        String moveText = "Nothing occurred";
        if (move.equals("Attack")){
            int dmg = attack();
            int staminaUsed = staminaLoss();
            int dmgDealt = player.takeDamage(dmg);
            this.setStamina(Math.max(this.getStamina() - staminaUsed, 0));
            moveText = this.getName() + " dealt " + String.valueOf(dmgDealt) + " damage to " + player.getName() + ".";
        }
        else if (move.equals("Bounce")){
            if (this.getStamina() == 0){
                moveText = "Bounce failed!";
            }
            else {
                if (!this.bounceWait) {
                    this.bounceWait = true;
                    int staminaUsed = staminaLoss();
                    this.setStamina(Math.max(this.getStamina() - staminaUsed, 0));
                    moveText = this.getName() + " used Bounce! Its preparing to land on the next turn!";
                }
                else {
                    this.bounceWait = false;
                    int dmg = bounceDmgDeal();
                    int dmgDealt = player.takeDamage(dmg);
                    moveText = this.getName() + " landed on " + player.getName() + " dealing " + String.valueOf(dmgDealt) + " damage!";
                }
            }
        }
        else if (move.equals("Calm Down")){
            if (this.getStamina() == this.getMaxStamina()){
                moveText = this.getName() + " used Calm Down. It failed!";
            }
            int staminaRestored = this.calmDown();
            this.setStamina(this.getStamina() + staminaRestored);
            moveText = this.getName() + " drew a circle. Restored " + String.valueOf(staminaRestored) + " stamina.";
        }
        return moveText;
    }
    
    private int attack() {
        if (this.getStamina() == 0) {
            return 0;
        }
        int randDmg = ThreadLocalRandom.current().nextInt(this.getMinAtkPwr(), (this.getMaxAtkPwr() + 1));
        return randDmg;
    }

    private int bounceDmgDeal() {
        int randDmg = ThreadLocalRandom.current().nextInt(this.getMinAtkPwr() * 4, (this.getMaxAtkPwr() + 1) * 4);
        return randDmg;
    }

    private int staminaLoss(){
        if (this.bounceWait) {
            return 20;
        }
        return 5;
    }

    private int calmDown(){
        return 8;
    }

    @Override
    public int takeDamage(int dmg){
        int dmgDealt = (int) Math.min(this.getHealth(), dmg);
        this.setHealth(Math.max(this.getHealth() - dmg, 0));
        return dmgDealt;
    }
}