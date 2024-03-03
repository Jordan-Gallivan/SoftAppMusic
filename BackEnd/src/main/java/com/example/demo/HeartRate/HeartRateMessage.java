package com.example.demo.HeartRate;

public class HeartRateMessage {
    private int heartRate;

    public int getHeartRate(){
        return heartRate;
    }
    public void setHeartRate(int heartRate) {
        this.heartRate = heartRate;
    }
    public HeartRateMessage() {

    }
    public HeartRateMessage(int heartRate){
        this.heartRate = heartRate;
    }
}
