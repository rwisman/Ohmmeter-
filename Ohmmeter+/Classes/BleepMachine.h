//	http://stackoverflow.com/questions/2067267/where-to-start-with-audio-synthesis-on-iphone
//
//  BleepMachine.h
//  WgHeroPrototype
//
//  Created by Andy Buchanan on 05/01/2010.
//  Copyright 2010 Andy Buchanan. All rights reserved.
//
//	Modified 2011

#import <AudioToolbox/AudioToolbox.h>

// Class to implement sound playback using the AudioQueue API's
// Currently just supports playing one sine wave tones.
// The sound data is liitle-endian signed 16-bit @ 1KHz
//

class BleepMachine
{
    static void staticQueueCallback( void* userData, AudioQueueRef outAQ, AudioQueueBufferRef outBuffer )
    {
        BleepMachine* pThis = reinterpret_cast<BleepMachine*> ( userData );
        pThis->queueCallback( outAQ, outBuffer );
    }
    void queueCallback( AudioQueueRef outAQ, AudioQueueBufferRef outBuffer );
	
    AudioStreamBasicDescription m_outFormat;
	
    AudioQueueRef m_outAQ;
	
    enum 
    {
        kBufferSizeInFrames = 512, 
        kNumBuffers = 4,
        kSampleRate = 2000,
    };
	
    AudioQueueBufferRef m_buffers[kNumBuffers];
	
    bool m_isInitialised;
	
    struct Wave 
    {
        Wave(): volume(1.f), phase(0.f), frequency(0.f), fStep(0.f) {}
        float   volume;
        float   phase;
        float   frequency;
        float   fStep;
    };
	
    Wave wave;
	
public:
    BleepMachine();
    ~BleepMachine();
	
    bool Initialise();
    void Shutdown();
	
    bool Start();
    bool Stop();
	
    bool SetWave( float frequency, float volume );
};
