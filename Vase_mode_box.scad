/* Customizable vase mode box
 * By DrLex, v1.2 2023/05
 * Released under Creative Commons - Attribution - Share Alike license */

/* [General] */
// What model to generate. When using 'both', don't forget to split into two parts before starting vase mode prints.
render = "both"; //[box, lid, both]

/* [Dimensions] */
// Inner width of the box. All dimensions are mm.
width = 50.0; //[1:0.1:250]

// Inner depth of the box.
depth = 25.0; //[1:0.1:250]

// Inner height of the box.
height = 70.0; //[1:0.1:250]

// Overlap of the lid when placed on the box.
lid = 25.0; //[1:0.1:50]

// Total extra gap between the box and lid. You may need to try a few different values to get a perfect fit that is neither too loose nor too tight.
tolerance = 0.1; //[0:0.01:1]

// Wall thickness of the box. You must set wall thickness for vase mode in your slicer program to this same value when printing, and also set number of bottom layers such that vase mode starts above this height.
wall = 0.60; //[0.2:0.01:2]

/* [Shape] */
// Box shape
shape = "rectangle"; //[rectangle, cylinder]

// Rounded corner radius for rectangle shape
corner = 0; //[0:0.1:125]

// Number of segments for the cylinder shape (also controls smoothness of rounded corners, but then it is rounded to the nearest multiple of 4)
cylinder_segments = 64; //[3:128]

/* [Hidden] */
box_width = width + 2 * wall;
box_depth = depth + 2 * wall;
box_height = height + wall;
lid_width = box_width + tolerance + 2 * wall;
lid_depth = box_depth + tolerance + 2 * wall;
lid_height = lid + wall;
ridge_h = 0.8;
ridge_a = 30;  // angle of the ridge
ridge_r = tan(ridge_a) * ridge_h;  // cone radius needed to obtain angle
corner_r = min(corner, box_width/2, box_depth/2);
corner_r_lid = corner_r + wall;
segm = corner == 0 ? cylinder_segments : 4*round(cylinder_segments/4);


module rounded_box(width, depth, height, rad)
{
    wid2 = width - rad;
    dep2 = depth - rad;
    // A hull() of if/else statements proves terribly inefficient, hence put hull inside if/else
    if(2*rad >= width) {
        hull() {
            translate([rad, rad, 0]) cylinder(h=height, r=rad, $fn=segm);
            translate([rad, dep2, 0]) cylinder(h=height, r=rad, $fn=segm);
        }
    }
    else if(2*rad >= depth) {
        hull() {
            translate([rad, rad, 0]) cylinder(h=height, r=rad, $fn=segm);
            translate([wid2, rad, 0]) cylinder(h=height, r=rad, $fn=segm);
        }
    }
    else {
        hull() {
            translate([rad, rad, 0]) cylinder(h=height, r=rad, $fn=segm);
            translate([wid2, rad, 0]) cylinder(h=height, r=rad, $fn=segm);
            translate([wid2, dep2, 0]) cylinder(h=height, r=rad, $fn=segm);
            translate([rad, dep2, 0]) cylinder(h=height, r=rad, $fn=segm);
        }
    }
}

module rounded_lip(width, depth, height, rad, ridge)
{
    wid2 = width - rad;
    dep2 = depth - rad;
    rad2 = rad + ridge;
    if(2*rad >= width) {
        hull() {
            translate([rad, rad, 0]) cylinder(h=height, r1=rad, r2=rad2, $fn=segm);
            translate([rad, dep2, 0]) cylinder(h=height, r1=rad, r2=rad2, $fn=segm);
        }
    }
    else if(2*rad >= depth) {
        hull() {
            translate([rad, rad, 0]) cylinder(h=height, r1=rad, r2=rad2, $fn=segm);
            translate([wid2, rad, 0]) cylinder(h=height, r1=rad, r2=rad2, $fn=segm);
        }
    }
    else {
        hull() {
            translate([rad, rad, 0]) cylinder(h=height, r1=rad, r2=rad2, $fn=segm);
            translate([wid2, rad, 0]) cylinder(h=height, r1=rad, r2=rad2, $fn=segm);
            translate([wid2, dep2, 0]) cylinder(h=height, r1=rad, r2=rad2, $fn=segm);
            translate([rad, dep2, 0]) cylinder(h=height, r1=rad, r2=rad2, $fn=segm);
        }
    }
}


if(shape == "rectangle") {
    shift_box = render == "both" ? -(box_depth + 6) : -box_depth/2;
    shift_lid = render == "both" ? 6 : -lid_depth/2;

    if(render == "box" || render == "both") {
        translate([-box_width/2, shift_box, 0]) {
            if(corner_r == 0) {
                cube([box_width, box_depth, box_height]);
            }
            else {
                hull() {
                    rounded_box(box_width, box_depth, box_height,  corner_r);
                }
            }
        }
    }

    if(render == "lid" || render == "both") {
        translate([-lid_width/2, shift_lid, 0]) {
            if(corner_r == 0) {
                cube([lid_width, lid_depth, lid_height]);
                translate([0, 0, lid_height]) hull() {
                    cylinder(ridge_h, 0, ridge_r, $fn=4);
                    translate([lid_width, 0, 0]) cylinder(ridge_h, 0, ridge_r, $fn=4);
                    translate([lid_width, lid_depth, 0]) cylinder(ridge_h, 0, ridge_r, $fn=4);
                    translate([0, lid_depth, 0]) cylinder(ridge_h, 0, ridge_r, $fn=4);
                }
            }
            else {
                rounded_box(lid_width, lid_depth, lid_height,  corner_r_lid);
                translate([0, 0, lid_height]) rounded_lip(lid_width, lid_depth, ridge_h, corner_r_lid, ridge_r);
            }
        }
    }
}
else {
    shift_box = render == "both" ? -(box_depth/2 + 6) : 0;
    shift_lid = render == "both" ? lid_depth/2 + 6 : 0;

    if(render == "box" || render == "both") {
        scale_y_b = box_depth / box_width;
        translate([0, shift_box, 0]) scale([1, scale_y_b, 1]) cylinder(box_height, box_width/2, box_width/2, $fn=segm);
    }

    if(render == "lid" || render == "both") {
        scale_y_l = lid_depth / lid_width;
        translate([0, shift_lid, 0]) {
            scale([1, scale_y_l, 1]) {
                cylinder(lid_height, lid_width/2, lid_width/2, $fn=segm);
            }
            // unfortunately hull cannot make a 3D shape out of two 2D circles, so make a 3D contraption instead
            translate([0, 0, lid_height]) scale([1, scale_y_l, 1]) hull() {
                cylinder(ridge_h/2, lid_width/2, lid_width/2, $fn=segm);
                undo_scale = (lid_width/2 * scale_y_l + ridge_r) / (scale_y_l * (lid_width/2 + ridge_r));
                scale([1, undo_scale, 1]) cylinder(ridge_h, 0, lid_width/2 + ridge_r, $fn=segm);
            }
        }
    }
}
