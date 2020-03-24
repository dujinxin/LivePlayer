//
//  FYPlayerViewController.swift
//  FYLive
//
//  Created by 飞亦 on 3/22/20.
//  Copyright © 2020 COB. All rights reserved.
//

import UIKit
import IJKMediaFramework

class FYPlayerViewController: UIViewController {
    
    
    var player: IJKFFMoviePlayerController?
    //var urlStr = "http://flv.bn.netease.com/videolib3/1707/03/bGYNX4211/SD/movie_index.m3u8"
    //var urlStr = "rtmp://live.hkstv.hk.lxdns.com:1935/live/stream153"
    var urlStr = "rtmp://192.168.1.28:1935/rtmplive/room"
    
    //var mediaControl = IJKMediaControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white

        let url = URL(string: self.urlStr)
        
        let options = IJKFFOptions.byDefault()
        self.player = IJKFFMoviePlayerController(contentURL: url, with: options)
        self.player?.scalingMode = .aspectFill
        self.player?.shouldAutoplay = true
        
        self.player?.view.frame = CGRect(x: 0, y: 88, width: self.view.bounds.width, height: 180)
        self.player?.view.backgroundColor = UIColor.black
        //self.player?.view.autoresizingMask = .flexibleHeight
        
        self.view.addSubview((self.player?.view)!)
        
        self.installMovieNotificationObservers()
        
        
        
        let button = UIButton()
        button.frame = CGRect(x: (self.view.bounds.width - 100 )/2, y: (self.player?.view.frame.maxY ?? 0) + 50, width: 100, height: 50)
        button.setTitle("暂停", for: .normal)
        button.addTarget(self, action: #selector(play(btn:)), for: .touchUpInside)
        button.backgroundColor = UIColor.purple
        
        self.view.addSubview(button)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.isHidden = true
        
        guard let p = self.player else { return }
        if (!p.isPlaying()) {
            p.prepareToPlay()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.navigationBar.isHidden = false
    }
    deinit {
        self.removeMovieNotificationObservers()
    }
    
    @objc func play(btn: UIButton) {
        guard let p = self.player else { return }
        if p.isPlaying() {
            p.pause()
            btn.setTitle("播放", for: .normal)
        } else {
            p.play()
            btn.setTitle("暂停", for: .normal)
        }
    }
    func installMovieNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadStateDidChange(notify:)), name: .IJKMPMoviePlayerLoadStateDidChange, object: self.player)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackDidFinish(notify:)), name: .IJKMPMoviePlayerPlaybackDidFinish, object: self.player)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackIsPreparedToPlayDidChange(notify:)), name: .IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: self.player)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStateDidChange(notify:)), name: .IJKMPMoviePlayerPlaybackStateDidChange, object: self.player)
    }
    func removeMovieNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerLoadStateDidChange, object: self.player)
        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerPlaybackDidFinish, object: self.player)
        NotificationCenter.default.removeObserver(self, name: .IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: self.player)
        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerPlaybackStateDidChange, object: self.player)
    }
    
    @objc func loadStateDidChange(notify: Notification) {
        //    MPMovieLoadStateUnknown        = 0,
        //    MPMovieLoadStatePlayable       = 1 << 0,
        //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
        //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started

        guard let loadState = self.player?.loadState else { return }
        
        if ((loadState.rawValue & IJKMPMovieLoadState.playthroughOK.rawValue) != 0) {
            print("loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", loadState.rawValue);
        } else if ((loadState.rawValue & IJKMPMovieLoadState.stalled.rawValue) != 0) {
            print("loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", loadState.rawValue);
        } else {
            print("loadStateDidChange: ???: %d\n", loadState.rawValue);
        }
    }
    @objc func playbackDidFinish(notify: Notification) {
        //    MPMovieFinishReasonPlaybackEnded,
        //    MPMovieFinishReasonPlaybackError,
        //    MPMovieFinishReasonUserExited
        guard let reason = notify.userInfo?[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as? Int else { return }

        switch (reason) {
        
        case IJKMPMovieFinishReason.playbackEnded.rawValue:
            print("playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break
        case IJKMPMovieFinishReason.userExited.rawValue:
            print("playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break
        case IJKMPMovieFinishReason.playbackError.rawValue:
            print("playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break
        default:
            print("playbackPlayBackDidFinish: ???: %d\n", reason);
            break
        }
    }
    @objc func playbackIsPreparedToPlayDidChange(notify: Notification) {
        print("mediaIsPreparedToPlayDidChange\n")
    }
    @objc func playbackStateDidChange(notify: Notification) {
        //    MPMoviePlaybackStateStopped,
        //    MPMoviePlaybackStatePlaying,
        //    MPMoviePlaybackStatePaused,
        //    MPMoviePlaybackStateInterrupted,
        //    MPMoviePlaybackStateSeekingForward,
        //    MPMoviePlaybackStateSeekingBackward

        guard let playbackState = self.player?.playbackState else { return }
        
        switch (playbackState) {
        case IJKMPMoviePlaybackState.stopped:
            print("IJKMPMoviePlayBackStateDidChange %d: stoped", playbackState.rawValue);
            break
        case IJKMPMoviePlaybackState.playing:
            print("IJKMPMoviePlayBackStateDidChange %d: playing", playbackState.rawValue);
            break
        case IJKMPMoviePlaybackState.paused:
            print("IJKMPMoviePlayBackStateDidChange %d: paused", playbackState.rawValue);
            break
        case IJKMPMoviePlaybackState.interrupted:
            print("IJKMPMoviePlayBackStateDidChange %d: interrupted", playbackState.rawValue);
            break
        case IJKMPMoviePlaybackState.seekingForward,IJKMPMoviePlaybackState.seekingBackward:
            print("IJKMPMoviePlayBackStateDidChange %d: seeking", playbackState.rawValue);
            break
        default:
            print("IJKMPMoviePlayBackStateDidChange %d: unknown", playbackState.rawValue);
            break
        }
    }
}
