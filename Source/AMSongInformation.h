//
//  AMSongInformation.h
//  Amua
//
//  Created by Mathis & Simon Hofer on 28.11.06.
//  Copyright 2005-2007 Mathis & Simon Hofer.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//

#import <Cocoa/Cocoa.h>

/**
 * AMSongInformation represents the information that can be retreived
 * from the webservice for the playing song.
 * @ingroup Player
 */
@interface AMSongInformation : NSObject {

    NSString *artistName;
    NSString *albumName;
    NSString *trackName;
    NSImage *coverImage;
    int trackLength;
    NSString *radioStation;
    NSString *radioStationFeed;
    NSDate *creationDate;

}

/**
 * Return an AMSongInformation object initialized using the data of a dictionary.
 *
 * Allowed keys for the dictionary are:
 *  - artist = Artist name
 *  - album = Album name
 *  - track = Track name
 *  - track_duration = Track duration in seconds
 *  - station = Station name
 *  - station_feed = Station feed details (usually username)
 *  - album_cover_small = URL to the album cover
 * @param data The song data as dictionary.
 */
- (id)initWithDictionary:(NSDictionary *)data;

/**
 * Return the artist name.
 * @return The artist name.
 */
- (NSString *)artist;

/**
 * Return the album name.
 * @return the album name.
 */
- (NSString *)album;

/**
 * Return the track name.
 * @return The track name.
 */
- (NSString *)track;

/**
 * Return the image cover.
 * @return The image cover as NSImage.
 */
- (NSImage *)cover;

/**
 * Return the track length.
 * @return The track length in seconds.
 */
- (int)length;

/**
 * Return the track progress.
 * @return The track progress in seconds.
 */
- (int)progress;

/**
 * Return the station name.
 * @return The station name.
 */
- (NSString *)station;

/**
 * Return the station feed details.
 * @return The station feed details.
 */
- (NSString *)stationFeed;

/**
 * Return a short string representing the song information.
 * @return A short string from the song information.
 */
- (NSString *)shortString;

/**
 * Return the album URL.
 * @return An URL pointing to the album on the Last.fm website.
 */
- (NSURL *)url;

/**
 * Check if the song information contain an URL.
 * @return YES if song information contain an URL else NO.
 */
- (bool)hasURL;

/**
 * Compare the song information with other song information.
 * @return YES if the song information are equal else NO.
 */
- (bool)isEqualToSongInformation:(AMSongInformation *)songInfo;

/**
 * Check if the song information is valid.
 * @return YES if the song information is valid else NO.
 */
- (bool)isValid;

- (void)dealloc;

@end
