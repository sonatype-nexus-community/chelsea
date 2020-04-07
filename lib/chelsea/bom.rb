require 'ox'
require 'pry'

module Chelsea
  class Bom
    attr_reader :xml
    def initialize(dependencies)
      @xml = get_xml(dependencies)
    end

    def to_s
      Ox.dump(@xml)
    end

    private

    def get_xml(dependencies)
      doc = Ox::Document.new

      instruct = Ox::Instruct.new(:xml)
      instruct[:version] = '1.0'
      instruct[:encoding] = 'UTF-8'
      instruct[:standalone] = 'yes'
      doc << instruct

      bom = Ox::Element.new('bom')
      bom[:xmlns] = 'http://cyclonedx.org/schema/bom/1.1'
      bom[:version] = '1'
      doc << bom

      components = Ox::Element.new('components')
      dependencies.each do |k, (name, version)|
        component = Ox::Element.new('component')
        component[:type] = 'library'

        n = Ox::Element.new('name')
        n << name

        v = Ox::Element.new('version')
        v << version.version

        component << n
        component << v

        components << component
      end
      bom << components
      doc
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
end