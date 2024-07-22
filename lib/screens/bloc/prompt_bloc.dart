import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'prompt_event.dart';
part 'prompt_state.dart';

class PromptBlockBloc extends Bloc<PromptBlockEvent, PromptBlockState> {
  PromptBlockBloc() : super(PromptBlockInitial()) {
    on<PromptBlockEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
