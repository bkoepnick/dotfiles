from pymol import cmd
import time
import os

time.sleep(2)

cmd.do( 'run /Users/koepnick/scripts/pymol/obj_arrows.py' )
cmd.do( 'run /Users/koepnick/scripts/pymol/custom.py' )
#run /Users/koepnick/scripts/pymol/tmalign.py

cmd.set_key( 'CTRL-Z', cmd.zoom, [ "visible" ] )
cmd.set( 'ray_shadows', 0 )
cmd.bg_color( '[0.7, 0.7, 0.7]' )
cmd.hide( 'all' )
cmd.show( 'cartoon', 'all' )
cmd.set( 'cartoon_flat_sheets', 0 )
cmd.show( 'sticks', 'not (name c or name n)' )
cmd.remove( '(h. and (e. c extend 1))' )
cmd.set( 'stick_h_scale', 1 )
cmd.set( 'valence',  0 )
#hide sticks, e. H
util.cbc( 'e. C' )
cmd.disable( 'all' )
cmd.zoom( 'visible' )
cmd.set( 'ray_trace_mode', 1 )

if( cmd.get_names() ):
	cmd.enable( cmd.get_names()[0] )

# set homedir so `fetch` downloads pdbs to .pymol/
homedir = os.path.expanduser('~')
if os.getcwd() == homedir:
	os.chdir( os.path.join( homedir, '.pymol' ) )
