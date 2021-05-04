/*Processingを使用*/ //<>//

//Player
PImage[] doroImgs = new PImage[3];//アニメーション格納

//BackGround
PImage image;//背景
float backspeed=2.5;//背景スピード
float p;//背景をのⅩ軸,backspeedによって変化

//Button
int count = 0, pushCount = 2;
boolean push = false;//ボタン判定用

int timeCount = 0;

//パーティクル
Particle[] particles = new Particle[512];

PImage img;            // キラキラの画像
float buoyancy = -0.2; // 浮力の加速度（1フレームあたり）
float xflow = 1.0;     // 風速（1フレームあたり）
float yflow = -0.1;
float diff = 0.5;      // ランダムな拡散の最大加速度
float k0 = 0.1;       // 空気抵抗の係数÷質量

int countp = 0;

//shader
PShader sh;
float x, y;

//障害物ブロック
final int obj_num = 5;
boolean isExits[] = new boolean[obj_num];//障害物の配列に入ってるかどうか
float xPos[] = new float[obj_num];
float yPos[] = new float[obj_num];
float speed[] = new float[obj_num];
color col[] = new color[obj_num];
float ByPos[] = new float[]{360, 300, 240, 400, 270, 100, 200, 450};

//Stast Text
int wordCount;
String[] startWord = {"3", "2", "1", "GO!"};

//操作するキャラクタークラス
class MyCharacter{
  
  PVector pos = new PVector(); //キャラクターの位置
  float jy;//ジャンプ中の位置
  PVector vel = new PVector(); //キャラクターの初速度
  PVector acc = new PVector(); // キャラクターの加速度
  
}

MyCharacter myc;
float g = 2.5; // 重力加速度

//キャラクターをセットする
void setCharacter() {
  
  if(myc.pos.y==400){
    
    myc.pos.x = 100;
    myc.pos.y = 400;
    
  }
  
  pushCount--;
  myc.vel.x = 20 * cos(radians(90));
  myc.vel.y = -20 * sin(radians(60));
  
}

//パーティクル
class Particle {
  
  float x, y;    // 座標
  float vx, vy;  // 速度（1フレームあたり）
  float ax, ay;  // 加速度（1フレームあたり）
  boolean shown; // 表示するか
  
}

void setup(){
  
  //パーティクル
  frameRate(30);
  imageMode(CENTER);
  
  for (int i = 0; i < particles.length; i++) {
    
    particles[i] = new Particle();
    
  }
  
  randomSeed(millis());
  img = loadImage("sparkle.png");// キラキラの画像を読み込む
  img.resize(10 * 2, 10 * 2);
  
  //キャラクター
  myc = new MyCharacter();
  myc.pos.x=100;//キャラクターの初期x位置
  myc.pos.y=400;//キャラクターの初期y位置
  myc.acc.x = 0;//キャラクターの初期加速度x
  myc.acc.y = 1.0;//キャラクターの加速度y
  myc.jy=0;//ジャンプ中の初期位置
  
  //アニメーション読み込み
  for(int i = 0; i < doroImgs.length; i++)
    doroImgs[i] = loadImage("PlayerR" + i + ".png");
  frameRate(40);
  
  //背景
  image=loadImage("Renga.jpg");
  size(450, 450,P3D);
  
  //shader
  sh = loadShader("frag.glsl");
  sh.set("tex", img);
  sh.set("dim", (float)width, (float)height);
  
}

//プレイヤーのジャンプアニメーション
int JumpAnimation(){
  
  if(push == false){//スペースが押されていない
    if(frameCount % 3 == 0){
      
      count ++;//アニメーションの配列を変化
      
      if(count == doroImgs.length) count = 0;//配列が終わったら最初から
      
    }
  }else{//スペースが押されたら
        return 0;
  }
  
  return count;
  
}

//スペースキーを押されたかどうか
void keyPressed(){
  
  if(key == ' '){
    
      setCharacter();
      
      if(myc.pos.y!=400){
        push=true;
      }else{
        push=false;
      }
      
  }
  
}

//Shaderの警察ライトの移動
void ShaderKirai(){
  
  shader(sh);
  noStroke();
  fill(255, 255, 255, 153);
  
  x += 1.0;
  if(x>width){
    x = width;
    x *= -1;
  }
  if(x<0){
    x = 0;
    x *= -1;
  }
  y += 1.0;
  if(y>height){
    y = height;
    y *= -1;
  }
  if(y<0){
    y = 0;
    y *= -1;
  }
  
  ellipse(x, y, 200, 200);
  resetShader();
  
}

void draw(){
  
  //背景の描画
  beginShape();
  texture(image);
  vertex(0,0,p,0);
  vertex(0,450,p,450);
  vertex(450,450,450+p,450);
  vertex(450,0,450+p,0);
  endShape();
  
  //画像
  p+=backspeed;
  if(p>=1350)p=0;
  
  timeCount ++;
  println(timeCount);
  
  if (wordCount >= startWord.length) {
    
    ShaderKirai();
    //パーティクル
    // パーティクルの発生
    {
      // 512個のパーティクルを使い回しする
      Particle p = particles[countp % particles.length];
      countp++;
      p.shown = true;
      
      // 初期座標
      p.x = myc.pos.x;
      p.y = myc.pos.y;
      
      // 初速度
      p.vx = 0;
      p.vy = 0;
      p.ax = 0;
      p.ay = 0;
    }
    
    for (int i = 0; i < particles.length; i++) {
      
      Particle p = particles[i];
      
      // 表示しない場合は飛ばす
      if (p.shown == false) continue;
      
      // 流れとの相対速度を求める
      float vx = p.vx - xflow;
      float vy = p.vy - yflow;
      
      // 流れに押されて流される力＋浮力
      p.ax = -k0 * vx;
      p.ay = -k0 * vy + buoyancy;
      
      // ランダムな動きを加えて拡散させる
      float b = random(diff);
      float d = random(2 * PI);
      p.ax += b * sin(d);
      p.ay += b * cos(d);
      p.vx -= p.ax;
      p.vy += p.ay;
      p.x += p.vx;
      p.y += p.vy;
      
      // 画面から十分外に出たら表示しない
      if (p.y < -100) {
        p.shown = false;
        continue;
      }
      
      image(img,p.x-3,p.y);
      
    }
  
  //操作するキャラクター
    myc.vel.add(myc.acc);
    myc.pos.add(myc.vel);
    if(myc.pos.y>=400){
      myc.pos.y=400;
      pushCount=2;
      push=false;
    }
    
    if(myc.pos.y<30)myc.pos.y=30;
    image(doroImgs[JumpAnimation()], myc.pos.x, myc.pos.y);//プレイヤーの線画
    
    //ブロックの描画
    //3％の確率で障害物を出す
    if(random(0, 100) < 3){
      
      //障害物描画
      for(int i = 0; i < obj_num; i++){
        
        //障害物なし
        if(!isExits[i]){
          isExits[i] = true;
          xPos[i] = width;//右端に設置
          yPos[i] = ByPos[(int)random(8)];
          speed[i] = random(2, 10);
          colorMode(HSB);
          col[i] = color(random(0,255), 255, 255);
          colorMode(RGB);
          break;//生成したら抜ける
        }
        
      }
      
    }
    //障害物描画
    for(int i = 0; i < obj_num; i++){
      
      //障害物あり
      if(isExits[i]){
        
        xPos[i] -= speed[i];//左に移動
        if(xPos[i] < 0){//画面はみだし
          isExits[i] = false;
          continue;//次の障害物へ
          
        }
        
        fill(col[i]);
        noStroke();
        rect(xPos[i], yPos[i], 30, 30);
        Initialize(i);
        
      }
      
    }
    
  }else {
    
    countReady();
    wordCount++;
    
  }
  
}

//最初のカウントダウン
void countReady() {
  
  noFill();
  frameRate(40);
  textSize(100);
  textAlign(CENTER);
  text(startWord[wordCount], width/2, height/2);
  
}

void Initialize(int i){
  
  /*------ 当たり判定 ------*/
  if(max(myc.pos.x, xPos[i]) < min(myc.pos.x + 20, xPos[i] + 30)
    && max(myc.pos.y, yPos[i]) < min(myc.pos.y + 20, yPos[i] + 30)){
    println("当たった");
    noLoop();
    GameOver();
  }
  
}

void GameOver(){
  
  background(0);
  color(255);
  textSize(40);
  textAlign(CENTER);
  text("Game Over", width/2, height/2);
  GAMEOVER_Comment();
  
}

void GAMEOVER_Comment() {
  
  textAlign(CENTER);
  textSize(30);
  text("see you next", width/2, height/2 + 50);
  
}
