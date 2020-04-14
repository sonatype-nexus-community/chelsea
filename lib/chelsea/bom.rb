# frozen_string_literal: true

require 'securerandom'
require 'ox'

module Chelsea
  # Class to convext dependencies to BOM xml
  class Bom
    attr_accessor :xml
    def initialize(dependencies)
      @dependencies = dependencies
      @xml = _get_xml
    end

    def to_s
      Ox.dump(@xml).to_s
    end

    def random_urn_uuid
      'urn:uuid:' + SecureRandom.uuid
    end

    private

    def _get_xml
      doc = Ox::Document.new
      doc << _root_xml
      bom = _bom_xml
      doc << bom
      components = Ox::Element.new('components')
      @dependencies.each do |_, (name, version)|
        components << _component_xml(name, version)
      end
      bom << components
      doc
    end

    def _bom_xml
      bom = Ox::Element.new('bom')
      bom[:xmlns] = 'http://cyclonedx.org/schema/bom/1.1'
      bom[:version] = '1'
      bom[:serialNumber] = random_urn_uuid
      bom
    end

    def _root_xml
      instruct = Ox::Instruct.new(:xml)
      instruct[:version] = '1.0'
      instruct[:encoding] = 'UTF-8'
      instruct[:standalone] = 'yes'
      instruct
    end

    def _component_xml(name, version)
      component = Ox::Element.new('component')
      component[:type] = 'library'
      n = Ox::Element.new('name')
      n << name
      v = Ox::Element.new('version')
      v << version.version
      purl = Ox::Element.new('purl')
      purl << Chelsea.to_purl(name, version.version)
      component << n << v << purl
      component
    end

    def _show_logo
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
