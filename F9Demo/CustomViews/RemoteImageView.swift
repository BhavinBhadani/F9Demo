import SwiftUI

struct RemoteImageView: View {
    @ObservedObject var remoteImageModel: RemoteImageModel
    
    init(urlString: String?) {
        remoteImageModel = RemoteImageModel(urlString: urlString)
    }
    
    var body: some View {
        Image(uiImage: remoteImageModel.image ?? RemoteImageView.defaultImage!)
            .resizable()
            .scaledToFit()
            .frame(width: 70, height: 70)
    }
    
    static var defaultImage = UIImage(named: "ic_unknown")
}

struct RemoteImageView_Previews: PreviewProvider {
    static var previews: some View {
        RemoteImageView(urlString: nil)
    }
}
