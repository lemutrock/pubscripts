#!/usr/bin/python
import os
import mutagen
from mutagen.easyid3 import EasyID3
from mutagen.mp3 import EasyMP3
from yandex_music.client import Client

username = input("Your yandex login: ")
password = input("Your password:")

client = Client.from_credentials(username, password)

tracks = client.users_likes_tracks()

ignorlist = ["Alice Cooper", "Alice In Chains", "Dance With the Dead", "The Subways", "Bullet For My Valentine", "Бранимир", "Twisted Sister", "Metallica", "Король и Шут", "Five Finger Death Punch", "Manowar", "Smokie", "Faunts", "Marilyn Manson", "Ария", "Akira Yamaoka", "Pink Floyd", "Кукрыниксы"]

for track in tracks:
    title = track.track.title
    try:
        artist = track.track.artists[0].name
        album = track.track.albums[0].title
        if artist in ignorlist:
            print("skipping")
        else:
            print("downloading queue:")
            print("title:{} | artist:{} | album:{}".format(title, artist, album))
            try:
                fname = "{} - {}.mp3".format(artist, title)
                if os.path.isfile(fname):
                    print("{} already downloaded".format(fname))
                    id3data = EasyMP3(fname)
                    id3data.delete()
                    id3data["title"] = u"{}".format(title)
                    id3data["artist"] = u"{}".format(artist)
                    id3data["album"] = u"{}".format(album)
                    id3data.save()
                else:
                    track.track.download(fname)
                    id3data = EasyMP3(fname)
                    id3data.delete()
                    id3data["title"] = u"{}".format(title)
                    id3data["artist"] = u"{}".format(artist)
                    id3data["album"] = u"{}".format(album)
                    id3data.save()
            except Exception:
                print("Network error occured")
    except IndexError:
        print("exception occured")

exit()
