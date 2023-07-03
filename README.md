# Fairchild Republic A-10A Thunderbolt

This is a simulation of the A-10A Thunderbolt, used by the United States Air Force. 

A Work in Progress manual for the aircraft can be found at the following link: https://github.com/l0k1/A-10/wiki

## Notes

The model was originally constructed in Realsoft3D (linux beta V4.5), exported as a .OBJ format file and imported into AC3D where it was converted into .ac format and textured.

The accuracy of the model is heavily dependent on the data and drawings available for it, and in most cases, the side, front and top views in a typical 3-view drawing rarely align correctly or measure consistently.  For example, when the model is scaled to the correct length, the wing-span is likely to be a little out.

## Flight Data Model

The Flight Data Model uses the FlightGear YASim fdm solver, which uses a combination of aircraft geometry and performance data to generate the flight model.

Apart from the basic length, span and height of the aircraft, most of the measurements needed for YASim are not generally available so after uniformly scaling the 3d model to one of the basic measurements i.e. length, the geometry data was taken from the model.

While this may not give the most accurate numbers, with respect to the original aircraft, it does mean that what you fly matches pretty closely to what you see, at least as far as the geometry is concerned.

Information on the A-10s performance is fairly abundant but achieving the full performance has proved difficult so the current fdm should be regarded as developmental and still incorporating a lot of guesswork.

While the low altitude performance seems more or less acceptable, it cant reach it's sevice ceiling of 45,000ft and I have done little testing of the single engine loiter/cruise modes.

The approach parameters have required even more guesswork.  They are based upon a few photographs I was able to find showing the aircraft in what appeared to be the final approach stages, and whatever info I was able to find.

## Thanks

Thanks to everyone who has contributed to the project over the years. Unfortunately not everyone is named, neither is details of their contributions, however I have compiled a list based on those who I can find info on below:

- Lee Elliott (Initial developer)
- Alexis Bory (Weapon systems, Models, Main developer 2007+)
- David Bastien (Fuel + engine systems)
- Pinto (OPRF Compatibility, Multiplayer damage support, Bugfixes)
- Rudolf (Conversion to Emesary based damage system)
- JMaverick16 (Tactical Systems, Updates, Liveries)
- Zorka (Main developer 2021+)
- SammySkycrafts (Main developer 2021+ - Weapon system overhaul, tactical system overhaul, minor 3D work)