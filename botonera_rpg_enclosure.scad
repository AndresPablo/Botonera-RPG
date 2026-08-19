// =============================================================================
// PROYECTO: Botonera de Sonido para Rol (TTRPG Soundboard)
// Repositorio: https://github.com/AndresPablo/Botonera-RPG
// Modelo 3D Paramétrico de Gabinete / Caja (OpenSCAD)
// =============================================================================

/* [Vista y Modo de Renderizado] */
// Selecciona qué pieza mostrar para previsualizar o exportar a STL
PART = "both"; // ["both", "bottom", "top", "exploded"]

// Separación en modo explosionado (mm)
exploded_gap = 40;

/* [Dimensiones Generales del Gabinete] */
box_width       = 145.0; // Ancho exterior X (mm)
box_depth       = 105.0; // Profundidad exterior Y (mm)
box_height      = 34.0;  // Altura exterior Z (mm)
wall_thickness  = 2.6;   // Grosor de pared (mm)
bottom_thick    = 2.4;   // Grosor de base inferior (mm)
top_thick       = 2.4;   // Grosor de tapa superior (mm)
corner_radius   = 5.0;   // Radio de redondeo de esquinas (mm)
lip_height      = 2.0;   // Altura del labio de encastre (mm)
lip_tolerance   = 0.25;  // Holgura de encastre (mm)

/* [Teclado Matricial 4x4] */
// Dimensiones del hueco / bajo relieve para teclado de membrana 4x4
keypad_width       = 69.5;  // Ancho del teclado (mm)
keypad_length      = 76.5;  // Largo del teclado (mm)
keypad_recess      = 1.0;   // Profundidad del bajo relieve (mm)
keypad_slot_w      = 23.0;  // Ancho de ranura para cable cinta (mm)
keypad_slot_h      = 3.5;   // Alto de ranura para cable cinta (mm)
keypad_pos_x       = 14.0;  // Posición X desde borde izquierdo interno
keypad_pos_y       = 12.0;  // Posición Y desde borde frontal interno

/* [Parlante 3W] */
speaker_dia        = 40.0;  // Diámetro exterior del cono (mm) (30mm a 50mm)
speaker_rim_dia    = 44.0;  // Diámetro exterior del borde de fijación (mm)
speaker_rim_h      = 3.0;   // Altura de pared de soporte interno del parlante (mm)
speaker_pos_x      = 112.0; // Posición X del centro del parlante
speaker_pos_y      = 65.0;  // Posición Y del centro del parlante
grill_hole_dia     = 2.8;   // Diámetro de orificios de la rejilla acústica (mm)
grill_hole_spacing = 4.5;   // Espaciado entre orificios (mm)

/* [Conectores y Puertos en Paredes] */
// Puerto USB Arduino Nano (Pared Trasera)
usb_cutout_w       = 11.0;  // Ancho corte USB (mm)
usb_cutout_h       = 7.5;   // Alto corte USB (mm)
usb_pos_x          = 28.0;  // Posición X del centro del USB en pared trasera
usb_pos_z          = 10.0;  // Altura del centro del USB respecto a la base

// Jack de Audio 3.5 mm TRS Chasis (Pared Lateral Derecha)
jack_hole_dia      = 6.2;   // Diámetro orificio rosca Jack 3.5mm (mm)
jack_pos_y         = 35.0;  // Posición Y en pared lateral derecha
jack_pos_z         = 14.0;  // Altura del centro del Jack respecto a la base

// Interruptor de Encendido ON/OFF (Pared Trasera)
switch_cutout_w    = 13.5;  // Ancho orificio interruptor (mm)
switch_cutout_h    = 8.8;   // Alto orificio interruptor (mm)
switch_pos_x       = 115.0; // Posición X del centro en pared trasera
switch_pos_z       = 14.0;  // Altura del centro del interruptor

// Ranura MicroSD DFPlayer (Opcional - Pared Lateral Izquierda)
sd_slot_enabled    = true;
sd_slot_w          = 14.0;  // Ancho ranura MicroSD (mm)
sd_slot_h          = 3.2;   // Alto ranura MicroSD (mm)
sd_pos_y           = 50.0;  // Posición Y en pared lateral izquierda
sd_pos_z           = 10.5;  // Altura respecto a la base

/* [Tornillos y Postes de Montaje M3] */
screw_hole_dia     = 3.2;   // Diámetro pasante M3 (mm)
screw_head_dia     = 6.0;   // Diámetro de cabeza avellanada/cilíndrica M3 (mm)
screw_head_depth   = 2.0;   // Profundidad de avellanado (mm)
post_outer_dia     = 7.5;   // Diámetro exterior de los postes (mm)
insert_hole_dia    = 4.0;   // Diámetro para inserto roscado M3 de latón o roscado directo
post_inset         = 7.0;   // Distancia de centros de postes a bordes exteriores (mm)

/* [Standoffs Internos para Arduino Nano y DFPlayer / PCB] */
enable_pcb_standoffs = true;
standoff_dia       = 6.0;
standoff_hole_dia  = 2.2;   // Para tornillos autorroscantes M2 / M2.5
standoff_height    = 4.5;   // Altura de elevación sobre el fondo (mm)

// Calidad de curvas
$fn = 40;
eps = 0.02; // Holgura para evitar z-fighting en diferencias booleanas

// =============================================================================
// CÁLCULOS DERIVADOS
// =============================================================================
inner_w = box_width - 2 * wall_thickness;
inner_d = box_depth - 2 * wall_thickness;
bottom_h = box_height * 0.65;
top_h = box_height - bottom_h;

// =============================================================================
// MÓDULOS DE UTILIDAD
// =============================================================================
module rounded_cube(size, r, center = false) {
    w = size[0];
    d = size[1];
    h = size[2];
    rad = min(r, min(w/2, d/2));
    
    translate(center ? [-w/2, -d/2, -h/2] : [0, 0, 0])
    hull() {
        translate([rad, rad, 0]) cylinder(r = rad, h = h);
        translate([w - rad, rad, 0]) cylinder(r = rad, h = h);
        translate([w - rad, d - rad, 0]) cylinder(r = rad, h = h);
        translate([rad, d - rad, 0]) cylinder(r = rad, h = h);
    }
}

module speaker_acoustic_grill(outer_dia, hole_dia, spacing, thickness) {
    rad = outer_dia / 2;
    intersection() {
        cylinder(r = rad - 1.5, h = thickness + 2*eps, center = true);
        union() {
            for (x = [-rad : spacing : rad]) {
                for (y = [-rad : spacing : rad]) {
                    if (sqrt(x*x + y*y) + hole_dia/2 < rad - 1.0) {
                        translate([x, y, 0])
                            cylinder(d = hole_dia, h = thickness + 4*eps, center = true, $fn=16);
                    }
                }
            }
        }
    }
}

// =============================================================================
// CAJA INFERIOR (BOTTOM SHELL)
// =============================================================================
module bottom_box() {
    difference() {
        union() {
            rounded_cube([box_width, box_depth, bottom_h], corner_radius);
            
            // Labio de encastre perimetral
            translate([wall_thickness + lip_tolerance, wall_thickness + lip_tolerance, bottom_h - eps])
                rounded_cube([
                    inner_w - 2*lip_tolerance, 
                    inner_d - 2*lip_tolerance, 
                    lip_height + eps
                ], max(1.0, corner_radius - wall_thickness));
                
            corner_posts(bottom_h, is_bottom = true);
            
            if (enable_pcb_standoffs) {
                pcb_mounts();
            }
        }
        
        // Vaciado interior
        translate([wall_thickness, wall_thickness, bottom_thick])
            rounded_cube([inner_w, inner_d, bottom_h + lip_height + 2*eps], max(0.5, corner_radius - wall_thickness));
            
        translate([wall_thickness + 1.2, wall_thickness + 1.2, bottom_thick])
            rounded_cube([inner_w - 2.4, inner_d - 2.4, bottom_h + lip_height + 4*eps], max(0.5, corner_radius - wall_thickness - 1.2));
            
        // Orificios pasantes con avellanado
        screw_holes_bottom();
        
        // Puerto USB Arduino Nano (Pared trasera)
        translate([usb_pos_x - usb_cutout_w/2, box_depth - wall_thickness - 2*eps, usb_pos_z - usb_cutout_h/2])
            cube([usb_cutout_w, wall_thickness + 4*eps, usb_cutout_h]);
            
        // Interruptor ON/OFF (Pared trasera)
        translate([switch_pos_x - switch_cutout_w/2, box_depth - wall_thickness - 2*eps, switch_pos_z - switch_cutout_h/2])
            cube([switch_cutout_w, wall_thickness + 4*eps, switch_cutout_h]);
            
        // Jack 3.5mm (Pared lateral derecha)
        translate([box_width - wall_thickness - 2*eps, jack_pos_y, jack_pos_z])
            rotate([0, 90, 0])
                cylinder(d = jack_hole_dia, h = wall_thickness + 4*eps);
                
        // Ranura MicroSD DFPlayer (Pared lateral izquierda)
        if (sd_slot_enabled) {
            translate([-eps, sd_pos_y - sd_slot_w/2, sd_pos_z - sd_slot_h/2])
                cube([wall_thickness + 2*eps, sd_slot_w, sd_slot_h]);
        }
        
        rubber_feet_recesses();
        bottom_ventilation_slots();
    }
}

// =============================================================================
// TAPA SUPERIOR (TOP LID / PANEL)
// =============================================================================
module top_lid() {
    difference() {
        union() {
            rounded_cube([box_width, box_depth, top_h], corner_radius);
            
            corner_posts(top_h, is_bottom = false);
                
            // Anillo centrador para el parlante
            translate([speaker_pos_x, speaker_pos_y, top_h - top_thick - speaker_rim_h])
                difference() {
                    cylinder(d = speaker_rim_dia, h = speaker_rim_h);
                    translate([0, 0, -eps])
                        cylinder(d = speaker_dia + 0.5, h = speaker_rim_h + 2*eps);
                }
        }
        
        // Vaciado interior de la tapa
        translate([wall_thickness, wall_thickness, -eps])
            rounded_cube([inner_w, inner_d, top_h - top_thick + eps], max(0.5, corner_radius - wall_thickness));
            
        translate([wall_thickness, wall_thickness, -eps])
            rounded_cube([inner_w, inner_d, lip_height + 0.5], max(0.5, corner_radius - wall_thickness));
            
        // Bajo relieve para teclado 4x4
        translate([keypad_pos_x, keypad_pos_y, top_h - keypad_recess])
            cube([keypad_width, keypad_length, keypad_recess + 2*eps]);
            
        // Ranura pasante para cable plano de 8 pines
        translate([keypad_pos_x + (keypad_width - keypad_slot_w)/2, keypad_pos_y + 2.0, -eps])
            cube([keypad_slot_w, keypad_slot_h, top_h + 2*eps]);
            
        // Rejilla de parlante
        translate([speaker_pos_x, speaker_pos_y, top_h - top_thick/2])
            speaker_acoustic_grill(speaker_dia, grill_hole_dia, grill_hole_spacing, top_thick * 2);
            
        screw_holes_top();
        
        // Grabado de texto
        translate([speaker_pos_x, speaker_pos_y - speaker_dia/2 - 10.0, top_h - 0.4])
            linear_extrude(height = 0.5)
                text("BOTONERA RPG", size = 4.5, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
    }
}

// =============================================================================
// POSTES, FIJACIÓN Y DETALLES
// =============================================================================
module corner_posts(h, is_bottom = true) {
    post_positions = [
        [post_inset, post_inset],
        [box_width - post_inset, post_inset],
        [box_width - post_inset, box_depth - post_inset],
        [post_inset, box_depth - post_inset]
    ];
    for (pos = post_positions) {
        translate([pos[0], pos[1], 0])
            cylinder(d = post_outer_dia, h = h);
    }
}

module screw_holes_bottom() {
    post_positions = [
        [post_inset, post_inset],
        [box_width - post_inset, post_inset],
        [box_width - post_inset, box_depth - post_inset],
        [post_inset, box_depth - post_inset]
    ];
    for (pos = post_positions) {
        translate([pos[0], pos[1], -eps]) {
            cylinder(d = screw_hole_dia, h = bottom_h + 2*eps);
            cylinder(d = screw_head_dia, h = screw_head_depth + eps);
        }
    }
}

module screw_holes_top() {
    post_positions = [
        [post_inset, post_inset],
        [box_width - post_inset, post_inset],
        [box_width - post_inset, box_depth - post_inset],
        [post_inset, box_depth - post_inset]
    ];
    for (pos = post_positions) {
        translate([pos[0], pos[1], -eps])
            cylinder(d = insert_hole_dia, h = top_h - top_thick + eps);
    }
}

module pcb_mounts() {
    nano_x = 18.0;
    nano_y = 60.0;
    nano_w = 44.0;
    nano_d = 18.0;
    
    nano_mount_coords = [
        [nano_x, nano_y],
        [nano_x + nano_w, nano_y],
        [nano_x + nano_w, nano_y + nano_d],
        [nano_x, nano_y + nano_d]
    ];
    for (pt = nano_mount_coords) {
        translate([pt[0], pt[1], bottom_thick - eps])
            difference() {
                cylinder(d = standoff_dia, h = standoff_height);
                translate([0, 0, -eps])
                    cylinder(d = standoff_hole_dia, h = standoff_height + 2*eps);
            }
    }
}

module rubber_feet_recesses() {
    feet_inset = 12.0;
    feet_dia = 10.0;
    feet_depth = 0.8;
    coords = [
        [feet_inset, feet_inset],
        [box_width - feet_inset, feet_inset],
        [box_width - feet_inset, box_depth - feet_inset],
        [feet_inset, box_depth - feet_inset]
    ];
    for (c = coords) {
        translate([c[0], c[1], -eps])
            cylinder(d = feet_dia, h = feet_depth + eps);
    }
}

module bottom_ventilation_slots() {
    slot_w = 2.2;
    slot_len = 18.0;
    start_x = 65.0;
    start_y = 20.0;
    for (i = [0 : 7]) {
        translate([start_x + i * 5.5, start_y, -eps])
            cube([slot_w, slot_len, bottom_thick + 2*eps]);
    }
}

// =============================================================================
// RENDERIZADO Y EXPORTACIÓN
// =============================================================================
if (PART == "bottom") {
    bottom_box();
} else if (PART == "top") {
    translate([0, box_depth, top_h])
        rotate([180, 0, 0])
            top_lid();
} else if (PART == "exploded") {
    color([0.25, 0.55, 0.85, 0.9])
        bottom_box();
    color([0.9, 0.25, 0.25, 0.85])
        translate([0, 0, bottom_h + exploded_gap])
            top_lid();
} else { // "both"
    color([0.25, 0.55, 0.85, 0.95])
        bottom_box();
    color([0.85, 0.85, 0.85, 0.95])
        translate([0, 0, bottom_h])
            top_lid();
}
