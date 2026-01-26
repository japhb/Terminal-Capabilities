# OS Support Lifetimes Affecting Unicode Support


## Key Unicode Releases

These releases are significant for one of the following reasons:

    * Terminal emulator feature/font support thresholds
    * Major additions to symbol sets
    * Before a large group of OS releases

Key releases:

    Version | Set Name | Reason
    --------|----------|-------
     1.1    | Uni1     | Most basic "Unicode support"; many core symbols
     3.2    | Uni3     | Braille, music, math, many other symbols
     7.0    | Uni7     | Emoji, arrows, dingbats, game pieces, n-grams, map symbols;
            |          | before all supported end-user OS releases except RHEL 7
            |          | and Solaris 10
    13.0    | Uni13    | Many new symbols; before all supported end-user OS
            |          | releases except NetBSD 9, RHEL 7/8, Solaris, Ubuntu ESM
            |          | (16.04, 18.04, 20.04?), and Windows 10 1607 E/1809 E
    16.0    | Uni16    | Many new symbols
    17.0+   | Full     | Moving marker for "latest Unicode"

"End-user OS" indicates an OS that is typically installed on end-user devices,
as opposed to embedded systems, containers, or data center servers.


## Unicode Release Dates

    Version | Emoji    | Released | Notes
    --------|----------|----------|--------
     1.0.0  |          | 1991-10  |
     1.0.1  |          | 1992-06  |
     1.1    |          | 1993-06  | Oldest 'Age' attribute; many core symbols
     2.0    |          | 1996-07  | First stable (additions only after this)
     2.1    |          | 1998-05  | * Euro sign, object replacement character
     3.0    |          | 1999-09  | Braille
     3.1    |          | 2001-03  | Western+Byzantine music, math letters/digits
     3.2    |          | 2002-03  | Many new symbols
     4.0    |          | 2003-04  | N-grams (1-, 2-, 4-, 6-), some misc symbols
     4.1    |          | 2005-03  | Named sequences, misc symbols, Ancient Greek music
     5.0    |          | 2006-07  | Some misc symbols
     5.1    |          | 2008-04  | Dominos, Mahjong, various misc symbols
     5.2    |          | 2009-10  | Misc symbols
     6.0    |  0.6     | 2010-10  | Emoji, cards, alchemy, regions, map symbols
     6.1    |  0.6     | 2012-01  | Some faces and symbols
     6.2    |  0.6     | 2012-09  | * Turkish Lira sign
     6.3    |  0.6     | 2013-09  | Bidi formatting
     7.0    |  0.7     | 2014-06  | Arrows, dingbats, misc symbols
     8.0    |  1.0,2.0 | 2015-06  | Skin tones, misc emoji, Kievan music
     9.0    |  3.0,4.0 | 2016-06  | Misc emoji, squared symbols
    10.0    |  5.0     | 2017-06  | Misc emoji and symbols
    11.0    | 11.0     | 2018-06  | Emoji synced to Unicode, misc emoji, xianqi
    12.0    | 12.0     | 2019-03  | Misc emoji, chess variations
    12.1    | 12.0     | 2019-05  | * Square era name Reiwa
    13.0    | 13.0     | 2020-03  | Major symbol/drawing additions
    14.0    | 14.0     | 2021-09  | Yearly September release, misc emoji, Znamenny music
    15.0    | 15.0     | 2022-09  | Misc emoji
    15.1    | 15.1     | 2023-09  |
    16.0    | 16.0     | 2024-09  | Major symbol/drawing additions
    17.0    | 17.0     | 2025-09  |


## OS Support Windows

The following is a table of LTS (Long Term Support) dates for various operating
systems, to compare against the dates at which various Unicode versions were
released.  Data from https://endoflife.date/tags/os .  Oracle Linux not listed
as it is a rebuild of RHEL with same version numbers and nearly same end dates.

    OS      | Version     | Release Date | Last End Date | Notes
    --------|-------------|--------------|---------------|-------------------------------
    Alpine  | 3.20        | 2024-05-22   | 2026-04-01    | Oldest supported Alpine
    Alpine  | 3.21        | 2024-12-05   | 2026-11-01    |
    Alpine  | 3.22        | 2025-05-30   | 2027-05-01    |
    Alpine  | 3.23        | 2025-12-04   | 2027-11-01    | Newest supported Alpine
    --------|-------------|--------------|---------------|-------------------------------
    Android | 13/API 33   | 2022-08-15   | ?             | Oldest supported Android
    Android | 14/API 34   | 2023-10-04   | ?             |
    Android | 15/API 35   | 2024-09-03   | ?             |
    Android | 16/API 36   | 2025-06-10   | ?             | Newest supported Android
    --------|-------------|--------------|---------------|-------------------------------
    Apple   |      iOS 18 | 2024-09-16   | ?             | Oldest supported standard iOS
    Apple   |      iOS 26 | 2025-09-15   | ?             | Newest supported standard iOS
    Apple   |   iPadOS 17 | 2023-09-18   | ?             | Oldest supported iPadOS
    Apple   |   iPadOS 18 | 2024-09-16   | ?             |
    Apple   |   iPadOS 26 | 2025-09-15   | ?             | Newest supported iPadOS
    Apple   |    macOS 14 | 2023-09-26   | ?             | Oldest supported macOS
    Apple   |    macOS 15 | 2024-09-16   | ?             |
    Apple   |    macOS 26 | 2025-09-15   | ?             | Newest supported macOS
    Apple   |     tvOS 26 | 2025-09-15   | ?             | Only supported tvOS
    Apple   | visionOS 26 | 2025-09-15   | ?             | Only supported visionOS
    Apple   |  watchOS 26 | 2025-09-15   | ?             | Only supported watchOS
    --------|-------------|--------------|---------------|-------------------------------
    CentOS  | Stream  9   | 2021-09-15   | 2027-05-31    | Oldest supported CentOS
    CentOS  | Stream 10   | 2024-12-12   | 2030-01-01    | Newest supported CentOS
    --------|-------------|--------------|---------------|-------------------------------
    Debian  | 11          | 2021-08-14   | 2026-08-31    | Oldest supported Debian
    Debian  | 12          | 2023-06-10   | 2028-06-30    |
    Debian  | 13          | 2025-08-09   | 2030-06-30    | Newest supported Debian
    --------|-------------|--------------|---------------|-------------------------------
    FreeBSD | stable/13   | 2021-04-13   | 2026-04-30    | Oldest supported FreeBSD
    FreeBSD | stable/14   | 2023-11-20   | 2028-11-30    |
    FreeBSD | stable/15   | 2025-12-02   | 2029-12-31    | Newest supported FreeBSD
    --------|-------------|--------------|---------------|-------------------------------
    KDE     | Plasma 5.27 | 2023-02-14   | ?             | Only supported KDE Plasma 5
    KDE     | Plasma 6.5  | 2025-10-21   | ?             | Only supported KDE Plasma 6
    --------|-------------|--------------|---------------|-------------------------------
    Mint    | 21.x        | 2022-07-31   | 2027-04-30    | Oldest supported Mint series
    Mint    | 22.x        | 2024-07-25   | 2029-04-30    |
    Mint    | LMDE 7      | 2025-10-14   | ?             | Newest supported Mint
    --------|-------------|--------------|---------------|-------------------------------
    NetBSD  |  9          | 2020-02-14   | ?             | Oldest supported NetBSD
    NetBSD  | 10          | 2024-03-28   | ?             | Newest supported NetBSD
    --------|-------------|--------------|---------------|-------------------------------
    RHEL    |  7 ELS      | 2014-06-10   | 2029-05-31    | Oldest supported RHEL
    RHEL    |  8 ELS      | 2019-05-07   | 2032-05-31    |
    RHEL    |  9 ELS      | 2022-05-18   | 2035-05-31    |
    RHEL    | 10 ELS      | 2025-05-20   | 2038-05-31    | Newest supported RHEL
    --------|-------------|--------------|---------------|-------------------------------
    Slackware | 15.0      | 2022-02-03   | ?             | Only supported Slackware
    --------|-------------|--------------|---------------|-------------------------------
    Solaris | 10          | 2005-01-31   | 2027-01-01    | Oldest supported OS!
    Solaris | 11.3        | 2015-10-26   | 2027-01-01    |
    Solaris | 11.4        | 2018-08-28   | 2037-11-01    | Longest supported OS!
    --------|-------------|--------------|---------------|-------------------------------
    SteamOS | 3           | 2022-03-01   | ?             | Only supported SteamOS
    --------|-------------|--------------|---------------|-------------------------------
    SUSE    | 5.2 Micro   | 2022-04-14   | 2026-04-30    | Oldest supported SUSE Micro
    SUSE    | 5.3 Micro   | 2022-10-25   | 2026-10-30    |
    SUSE    | 5.4 Micro   | 2023-04-20   | 2027-04-30    |
    SUSE    | 5.5 Micro   | 2023-10-12   | 2027-10-31    |
    SUSE    | 6.0 Micro   | 2024-06-06   | 2028-06-30    |
    SUSE    | 6.1 Micro   | 2024-11-26   | 2028-11-30    |
    SUSE    | 6.2 Micro   | 2025-11-04   | 2029-11-30    | Newest supported SUSE Micro
    --------|-------------|--------------|---------------|-------------------------------
    Tails   | 7           | 2025-09-18   | ?             | Only supported Tails
    --------|-------------|--------------|---------------|-------------------------------
    Ubuntu  | 16.04 ESM   | 2016-04-21   | 2026-04-02    | Oldest supported Ubuntu
    Ubuntu  | 18.04 ESM   | 2018-04-26   | 2028-04-01    |
    Ubuntu  | 20.04 ESM   | 2020-04-23   | 2030-04-02    |
    Ubuntu  | 22.04       | 2022-04-21   | 2032-04-09    | Oldest Ubuntu regular support
    Ubuntu  | 24.04       | 2024-04-25   | 2036-05-31    | Longest Ubuntu support
    Ubuntu  | 25.10       | 2025-10-09   | 2026-07-01    | Newest supported Ubuntu
    --------|-------------|--------------|---------------|-------------------------------
    Windows | 10 1607 E   | 2016-08-02   | 2026-10-13    | Oldest supported Windows
    Windows | 10 1809 E   | 2018-11-13   | 2029-01-09    |
    Windows | 10 21H2 E   | 2021-11-16   | 2027-01-12    |
    Windows | 10 21H2 IoT | 2021-11-16   | 2032-01-13    | Longest Win10 support
    Windows | 10 22H2 ESU | 2022-10-18   | 2028-10-10    | Newest supported Win10
    Windows | 11 23H2 E   | 2023-10-31   | 2026-11-10    | Oldest supported Win11
    Windows | 11 24H2     | 2024-10-01   | 2026-10-13    |
    Windows | 11 24H2 E   | 2024-10-01   | 2029-10-09    |
    Windows | 11 24H2 IoT | 2024-10-01   | 2034-10-10    | Longest Win11 support
    Windows | 11 25H2     | 2025-09-30   | 2027-10-12    |
    Windows | 11 25H2 E   | 2025-09-30   | 2028-10-10    | Newest supported Windows
