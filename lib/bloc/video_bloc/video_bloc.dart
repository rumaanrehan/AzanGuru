import 'package:chewie/chewie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'video_event.dart';
part 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final Map<int, ChewieController?> controllers = {};

  VideoBloc() : super(VideoInitial()) {
    on<LoadVideo>((event, emit) async {
      emit(VideoLoading(event.index));
      try {
        // if(_controllers.isNotEmpty){
        //   _controllers.forEach((index,ctrl){
        //     ctrl?.videoPlayerController.pause();
        //   });
        // }
        if (controllers[event.index] != null) {
          controllers[event.index]?.videoPlayerController.pause();
          controllers[event.index]?.pause();
        }

        // final controller = PodPlayerController(
        //   playVideoFrom: PlayVideoFrom.network(event.url),
        //   podPlayerConfig: const PodPlayerConfig(
        //     autoPlay: false,
        //     isLooping: false,
        //     wakelockEnabled: true,
        //   ),
        // );
        // await controller.initialise();
        // late VideoPlayerController controller;
        // ChewieController? chewieController;
        // controller = VideoPlayerController.networkUrl(Uri.parse(event.url))
        //   ..initialize().then((_) {
        //     chewieController = ChewieController(
        //       videoPlayerController: controller,
        //       autoPlay: false,
        //       looping: false,
        //       allowFullScreen: false,
        //       draggableProgressBar: false,
        //       allowMuting: false,
        //       allowPlaybackSpeedChanging: false,
        //       // additionalOptions: (context) {
        //       //   return <OptionItem>[];
        //       // },
        //       // optionsBuilder: (context, chewieOptions) {},
        //       // customControls: _buildOverlay(),
        //     );
        //   });
        controllers[event.index] = event.chewieController;
        emit(VideoLoaded(event.chewieController, event.index));
      } catch (e) {
        emit(VideoError("Failed to load video: $e", event.index));
      }
    });
    // on<PlayVideo>((event, emit) {
    //   _controllers[event.index]?.play();
    // });
    on<PauseVideo>((event, emit) {
      // _controllers[event.index]?.pause();
      for (ChewieController? controller in controllers.values) {
        if (controller != null) {
          controller.pause();
        }
        controller = null;
      }
    });
    on<StopVideo>((event, emit) {
      for (ChewieController? controller in controllers.values) {
        if (controller != null) {
          controller.dispose();
          controller.videoPlayerController.dispose();
        }
        controller = null;
      }
      emit(VideoInitial());
    });
  }

  @override
  Future<void> close() {
    for (final controller in controllers.values) {
      controller?.dispose();
    }
    return super.close();
  }
}
