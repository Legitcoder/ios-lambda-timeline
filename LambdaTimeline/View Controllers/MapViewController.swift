//
//  MapViewController.swift
//  LambdaTimeline
//
//  Created by Moin Uddin on 11/8/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import MapKit
class MapViewController: UIViewController, MKMapViewDelegate, PostControllerDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "PostAnnotationView")
        let posts = postController.posts.filter { $0.geotag != nil}
        mapView.addAnnotations(posts)
        // Do any additional setup after loading the view.
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let post = annotation as? Post else { return nil }
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "PostAnnotationView", for: post) as! MKMarkerAnnotationView
        
        annotationView.glyphTintColor = .red
        annotationView.canShowCallout = true
        
        return annotationView
        
    }
    
    var postController: PostController!

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBOutlet weak var mapView: MKMapView!
    

}
