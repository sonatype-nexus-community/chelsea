require 'bom_builder'
require "logger"

class Bom < Bombuilder
  def self.build(specs, bom_file_path: './bom.xml')
    # @gems and @licenses_list are used within
    # Bombuilder.specs_list. If we want to leverage licenses,
    # we should build the list
    @specs, @bom_file_path = specs, bom_file_path
    @gems = []
    @licenses_list = []
    @logger = Logger.new(STDOUT)
    specs_list
    _show_logo
    File.open(@bom_file_path, "w") {|file| file.write(build_bom(@gems))}
  end
  def self._show_logo
    logo = %Q(
                        -o/                             
                    -+hNmNN-                            
  .:+osyhddddyso/-``ody+-  .NN.                           
/mMMdhssooooooosyhdmhs/.    /Mm-                          
oMs`                `.-:.    oMNs.                     .  
`N.           `.              .+hNh+`                 +N. 
 yo -m`  -d` `dm.                `:smd+.            `yMM. 
 -m`mM/ -mN/`ddMs                    -sNh/         .dy-M- 
  dmdsd/m--dmo Nh   `o:      /o`       `+md-      :m/  N: 
  /y `Nd`  do  my   .dMy.  .hMy`         `oN+    om-   m: 
      +    .  `No     +NN+oNm:             .d+ `hd`    d: 
              `Mo      .dMMy     SBOM       `d+ms`     d: 
      `.      -M+     `yMhmNo`    BABY      `hN/-      d/ 
  /:  yd  /o  -M/    /NN/  +Nm:            +Nd.-mo     m+ 
  dm`/mmo-NMo /M-  .dMs`    `o/          /mN+   `hh.   N+ 
 -MMdN//NNhhMysm    /-                `+mMs`      +mo  N+ 
sN/Ny  hd``yMMh                    :yNNs.         `sm+M+ 
dd.``  ``   /d-   oy.          `/yNNh/`             .yM+ 
 `yNy/`            oMm`     `/sdMdo-                   .. 
   `/ymmys+///++shN+/Nm.   /NMNo.                         
       `-/+ooo+/:.`  :NN- /MMo`                           
                      -NNoNM+                             
                       :MMM+                              
                        :d/                               
)
    puts logo
  end
end